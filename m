From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH RFC] tun: dma engine support
Date: Wed, 13 Oct 2010 17:27:47 -0700
Message-ID: <AANLkTikyCBrXsvV_ZqYt7tHPRK4WGNLt8654Mhec70rB@mail.gmail.com>
References: <20101011205208.GA8527@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Walleij <linus.walleij@stericsson.com>,
	Anatolij Gustschin <agust@denx.de>,
	Magnus Damm <damm@opensource.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101011205208.GA8527@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ added Maciej ]

On Mon, Oct 11, 2010 at 1:52 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Simple hack to use dma engine for tun RX.
> Only one skb in flight at the moment.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>
> I am still looking at handling multiple skbs, but
> sending this out for early flames and improvement suggestions.
>
> Loopback testing seems to show only minor performance gains:
> this is not really suprising as data is hot in cache already.
> Where I would expect this to help more is with incoming
> traffic from an external NIC. This still needs to be tested.

Actually it is interesting that you did not see a performance loss
because the dma performs the transfer in memory so the destination
will be cache cold in the dma case compared to a cpu copy.

[..]
> +int tun_dma_copybreak = 0x10000;
> +module_param_named(dma_copybreak, tun_dma_copybreak, int, 0644);

What platform are you using for testing?  If this proves beneficial we
may need to adjust this value to have a platform specific default,
similar to how ioatdma sets tcp_dma_copybreak depending on the
hardware version.  You will notice that on Nehalem class hardware
(drivers/dma/ioat/dma_v3.c) the default is set to 256K effectively
disabling offload as the overhead of managing the dma engine
overshadows any offload advantage.

--
Dan
