From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Tue, 3 Oct 2017 14:50:00 -0700
Message-ID: <20171003145000.53683e21@cakuba>
References: <20171003200546.165731-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Manoj Gupta <manojgupta@chromium.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003200546.165731-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  3 Oct 2017 13:05:46 -0700, Matthias Kaehlcke wrote:
> nfp_eth_set_bit_config() is marked as __always_inline to allow gcc to
> identify the 'mask' parameter as known to be constant at compile time,
> which is required to use the FIELD_GET() macro.
> 
> The forced inlining does the trick for gcc, but for kernel builds with
> clang it results in undefined symbols:
> 
> drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.o: In function
>   `__nfp_eth_set_aneg':
> drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c:(.text+0x787):
>   undefined reference to `__compiletime_assert_492'
> drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c:(.text+0x7b1):
>   undefined reference to `__compiletime_assert_496'
> 
> These __compiletime_assert_xyx() calls would have been optimized away if
> the compiler had seen 'mask' as a constant.
> 
> Convert nfp_eth_set_bit_config() into a macro, which allows both gcc and
> clang to identify 'mask' as a compile time constant.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

:(

Is there no chance of fixing the constant propagation in the compiler?
