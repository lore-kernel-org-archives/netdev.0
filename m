From: Alistair John Strachan <alistair@devzero.co.uk>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 00:55:59 +0100
Message-ID: <200810260055.59783.alistair@devzero.co.uk>
References: <490380C8.6070003@simon.arlott.org.uk> <4903947A.3060206@gmail.com> <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752676AbYJYX4e@vger.kernel.org>
In-Reply-To: <20081025223443.GA30913@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 25 October 2008 23:34:43 Francois Romieu wrote:
> Jiri Slaby <jirislaby@gmail.com> :
> [...]
>
> > Ah, I thought I have broken hardware. I have similar problem, my mac is
> > initially all zeroes. When I set it up, it works until suspend. After
> > that I need to unbind the driver, bind it again, and it works then (mac
> > is still the set one).
> >
> > I'm out of the notebook right now, but it is 10ec:8168:
> > 06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> > RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 11f5
> >
> > I used it perfectly far later than 2.6.24 (maybe 2.6.26?), 2.6.27 is yet
> > defunct.
>
> 2.6.27 proper ? That's bad news.

Just thought I'd chime in to report the same thing. I don't use the NICs very
frequently, so I didn't notice until I read the report.

On this machine, the NICs are never put through a suspend/resume cycle, so
that doesn't seem to be anything to do with it.

The NICs should have incremental MAC addresses, since they're mainboard
devices. Put it this way, they used to.

Now when they're detected, one has the correct MAC, and the second has the
first 32bits of its MAC corrupted.

eth0: RTL8169sc/8110sc at 0xffffc2000001e000, 00:50:8d:b3:5f:de, XID 18000000 IRQ 23                                                          
eth1: RTL8169sc/8110sc at 0xffffc20000070000, d8:81:ec:10:5f:df, XID 18000000 IRQ 22

d8:81:ec:10 is corruption; 00:50:8d:b3 is correct.

I can bisect pretty easily if this is helpful.

-- 
Cheers,
Alistair.
