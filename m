From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3: netif_carrier_off runs too early; could still be
 queued when init fails
Date: Tue, 21 Feb 2006 13:39:47 -0800 (PST)
Message-ID: <20060221.133947.05470613.davem@davemloft.net>
References: <20060220194337.GA21719@locomotive.unixthugs.org>
	<1140540260.20584.6.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, akpm@osdl.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161064AbWBUVkE@vger.kernel.org>
To: mchan@broadcom.com
In-Reply-To: <1140540260.20584.6.camel@rh4>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 21 Feb 2006 08:44:20 -0800

> On Mon, 2006-02-20 at 14:43 -0500, Jeff Mahoney wrote:
> >  This patch moves the netif_carrier_off() call from tg3_init_one()->
> >  tg3_init_link_config() to tg3_open() as is the convention for most
> >  other network drivers.
> 
> I think moving netif_carrier_off() later is the right thing to do. We
> can also move it to the end of tg3_init_one() just before returning 0.

Agreed.

> >  I was getting a panic after a tg3 device failed to initialize due to DMA
> >  failure. The oops pointed to the link watch queue with spinlock debugging
> >  enabled. Without spinlock debugging, the Oops didn't occur.
> > 
> >  I suspect that the link event was getting queued but not executed until
> >  after the DMA test had failed and the device was freed. The link event
> >  was then operating on freed memory, which could contain anything. With this
> >  patch applied, the Oops no longer occurs. 
> 
> DMA test failed? What NIC device do you have? How did it fail?

I get this too with an old 5700 3COM card on sparc64.  I'll get
you some more detailed info later today, hopefully.

Jeff, please get some details for Michael about your failure
case.  Thanks.
