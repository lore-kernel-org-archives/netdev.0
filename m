From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: netif_carrier_off runs too early; could still
 be queued when init fails
Date: Tue, 21 Feb 2006 08:44:20 -0800
Message-ID: <1140540260.20584.6.camel@rh4>
References: <20060220194337.GA21719@locomotive.unixthugs.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>,
	"Linus Torvalds" <torvalds@osdl.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932260AbWBUSZO@vger.kernel.org>
To: "Jeff Mahoney" <jeffm@suse.com>
In-Reply-To: <20060220194337.GA21719@locomotive.unixthugs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-02-20 at 14:43 -0500, Jeff Mahoney wrote:
>  This patch moves the netif_carrier_off() call from tg3_init_one()->
>  tg3_init_link_config() to tg3_open() as is the convention for most
>  other network drivers.

I think moving netif_carrier_off() later is the right thing to do. We
can also move it to the end of tg3_init_one() just before returning 0.

> 
>  I was getting a panic after a tg3 device failed to initialize due to DMA
>  failure. The oops pointed to the link watch queue with spinlock debugging
>  enabled. Without spinlock debugging, the Oops didn't occur.
> 
>  I suspect that the link event was getting queued but not executed until
>  after the DMA test had failed and the device was freed. The link event
>  was then operating on freed memory, which could contain anything. With this
>  patch applied, the Oops no longer occurs. 

DMA test failed? What NIC device do you have? How did it fail?

Thanks.
