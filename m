From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH 2.6.20-rc7] 8139too KGDBoE fix
Date: Thu, 01 Mar 2007 19:22:06 +0300
Message-ID: <45E6FDAE.2040009@ru.mvista.com>
References: <1172746367.2515.31.camel@xenon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kgdb-bugreport@lists.sourceforge.net, netdev@vger.kernel.org,
	Mark Huth <mhuth@mvista.com>
To: komal <komal@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:27237 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965330AbXCAQWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 11:22:16 -0500
In-Reply-To: <1172746367.2515.31.camel@xenon>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

komal wrote:
> Hi all,

> 	As the discussion was going on about the effects of trapping the
> netpoll queue during KGDBoE debugging, I tried avoiding it. So in
> eth_pre_exception_handler() I did not set net_poll_trap to 1 and did not
> reset it back to 0 in eth_post_exception_handler() 

> file drivers/net/kgdboe.c

> static void eth_pre_exception_handler(void)
> {
>         /* Increment the module count when the debugger is active */
>         if (!kgdb_connected)
>                 try_module_get(THIS_MODULE);
> //      netpoll_set_trap(1);
> }
> 
> static void eth_post_exception_handler(void)
> {
>         /* decrement the module count when the debugger detaches */
>         if (!kgdb_connected)
>                 module_put(THIS_MODULE);
> //      netpoll_set_trap(0);
> }

    I'm afraid that was a wrong thing to do. We were talking only about 
disabling CONFIG_NETPOLL_TRAP option
   BTW, I don't see how CONFIG_NETPOLL_RX actually could influence anything -- 
looks like it just may be completely removed).

> 	As i started testing KGDBoe, 1st time I did 
> 	(gdb)info threads
> 	and it worked, but after that I set breakpoint
> 	(gdb)break link_path_walk
> 	after this any of the commands were not working and the test machine
> went in hang state. 
> 	To provide more information, I am working on an i386/x86_64 Athlon box,
> using 2.6.17 kernel and 100Mbps, full-duplex, VIA Rhine network card.

    This driver also seems prone to TX queue overwrites since its TX ring size 
is only 16.

> -Regards
>  Komal Nawandar

WBR, Sergei
