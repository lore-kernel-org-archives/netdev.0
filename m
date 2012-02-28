From: Andrei Warkentin <awarkentin@vmware.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Tue, 28 Feb 2012 09:43:52 -0800 (PST)
Message-ID: <1379096961.1660631.1330451032375.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
References: <4F4CFB94.2080302@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrei Warkentin <andreiw@vmware.com>,
	kgdb-bugreport@lists.sourceforge.net,
	Matt Mackall <mpm@selenic.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>
To: Jason Wessel <jason.wessel@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4CFB94.2080302@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

----- Original Message -----
> From: "Jason Wessel" <jason.wessel@windriver.com>
> To: "Andrei Warkentin" <awarkentin@vmware.com>
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>, "Andrei Warkentin"
> <andrey.warkentin@gmail.com>
> Sent: Tuesday, February 28, 2012 11:06:44 AM
> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
> 

> 
> All that netpoll_poll() did was to call netpoll_poll_dev().  I have
> not yet looked at the differences between kgdboe and the netkdb code
> you proposed but I would have suspected it also falls victim to the
> ethernet preemption problem which prevented kgdboe from ever being
> considered for a mainline merge.  Certainly there are ways to fix
> this
> problem but most involved changes to scheduling, core net code, or
> substantial driver specific changes.
> 

I see, I read up on the issues w.r.t. preemption. Could this be worked
around by modifiying affected drivers to bypass locking if they are
used in KDB context? Make some accessor netdev-specific lock/unlocks
that won't do anything if running in KDB context.

> 
> > 
> > This is slight OT, but...are WiFi drivers sufficiently similar that
> > netpoll "just works?"
> 
> Yes and no.  Yes, you could use the NET_POLL api to transmit packets
> if the driver implemented polling hooks, but no in the sense that
> most
> of the time you need a user space driver to manage the keys which are
> time sensitive for things like WPA (usually the job of wpa
> supplicant).  This is going to prevent you from having WiFi work at
> all while the kernel is in the critical exception state.
> 

Ah right. I was thinking just open networking. I should give that a try...

A
