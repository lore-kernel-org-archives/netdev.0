From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 16:01:22 -0700
Message-ID: <1375052482.3669.54.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-07-28 at 21:22 +0100, Ben Hutchings wrote:

> 
> Since we know lengths > 4K work, perhaps it would be worth testing with
> the fragment cache size reduced to 16K?  The driver would never
> previously have used RX buffers crossing 16K boundaries, except if SLOB
> was used (and that's an unlikely combination).

Sure, please note the following maths :

NET_SKB_PAD + 1536 + sizeof(struct skb_shared_info) = 1920

16384/1920 = 8

32768/1920 = 17

I don't think atl1c is used in any critical host (given it doesn't even
provide RX checksums and GRO ...), so I will provide a patch doing mere
page allocations.
