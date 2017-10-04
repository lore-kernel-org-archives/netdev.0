From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Wed, 4 Oct 2017 11:49:57 -0700
Message-ID: <20171004184957.GO173745@google.com>
References: <20171003200546.165731-1-mka@chromium.org>
 <1507140439.4434.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Manoj Gupta <manojgupta@chromium.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507140439.4434.14.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

El Wed, Oct 04, 2017 at 11:07:19AM -0700 Joe Perches ha dit:

> On Tue, 2017-10-03 at 13:05 -0700, Matthias Kaehlcke wrote:
> > nfp_eth_set_bit_config() is marked as __always_inline to allow gcc to
> > identify the 'mask' parameter as known to be constant at compile time,
> > which is required to use the FIELD_GET() macro.
> > 
> > The forced inlining does the trick for gcc, but for kernel builds with
> > clang it results in undefined symbols:
> 
> Can't you use local different FIELD_PREP/FIELD_GET macros
> with a different name without the BUILD_BUG tests?
> 
> i.e.:
> 
> #define NFP_FIELD_PREP(_mask, _val)				\
> ({								\
> 	((typeof(_mask))(_val) << __bf_shf(_mask)) & (_mask);	\
> })
> 
> #define NFP_FIELD_GET(_mask, _reg)				\
> ({								\
> 	(typeof(_mask))(((_reg) & (_mask)) >> __bf_shf(_mask));	\
> })
> 
> Then the __always_inline can be removed from
> nfp_eth_set_bit_config too.

Thanks for the suggestion. This seems a viable alternative if David
and the NFP owners can live without the extra checking provided by
__BF_FIELD_CHECK.
