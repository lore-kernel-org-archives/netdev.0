From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [BUG] 2.6.33-rc1 gianfar error message
Date: Mon, 21 Dec 2009 09:58:17 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
References: <20091220214447.GA10233@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Michael Guntsche" <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59562 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbZLUE2b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 23:28:31 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBL4SKoQ020809
	for <netdev@vger.kernel.org>; Sun, 20 Dec 2009 21:28:20 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBL4Woax002891
	for <netdev@vger.kernel.org>; Sun, 20 Dec 2009 22:32:51 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091220214447.GA10233@trillian.comsick.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>I recently installed 2.6.33-rc1 on my Routerboard RB600a to 
>give it a quick test. After rebooting with 2.6.33-rc1 I got an 
>almost immediate error message in my logs.
>
>Sorry for not being able to get more debug info. But with this 
>board I have a limit on the kernel size.
>
>wan selects TX queue 66, but real number of TX queues is 1 
>------------[ cut here ]------------ Badness at c01d846c 
[...]

>3c60c032 7f64db78 lan selects TX queue 66, but real number of 
>TX queues is 1 ------------[ cut here ]------------ Badness at 
>c01d846c [verbose debug info unavailable]
[...]
>Both NICs continue to work but the messages continue to appear 
>in the log with the number (66) varying a little bit every now 
>and then.
>
>I had a look at the recent changes and started testing the 
>different commits. I found out that I start getting the errors 
>with commmit
>
>fba4ed030cfae7efdb6b79a57b0c5a9d72c9de83
>gianfar: Add Multiple Queue Support
>
>Relevant dmesg output:
>eth0: Gianfar Ethernet Controller Version 1.2, 00:0c:42:28:de:4e
>eth0: Running with NAPI enabled
>eth0: :RX BD ring size for Q[0]: 256
>eth0:TX BD ring size for Q[0]: 256
>  alloc irq_desc for 32 on node 0
>  alloc kstat_irqs on node 0
>irq: irq 32 on host /soc8343@e0000000/pic@700 mapped to virtual irq 32
>  alloc irq_desc for 33 on node 0
>  alloc kstat_irqs on node 0
>irq: irq 33 on host /soc8343@e0000000/pic@700 mapped to virtual irq 33
>  alloc irq_desc for 34 on node 0[    0.546127]   alloc 
>kstat_irqs on node 0
>irq: irq 34 on host /soc8343@e0000000/pic@700 mapped to virtual irq 34
>eth1: Gianfar Ethernet Controller Version 1.2, 00:0c:42:28:de:4f
>eth1: Running with NAPI enabled
>eth1: :RX BD ring size for Q[0]: 256
>eth1:TX BD ring size for Q[0]: 256
>Freescale PowerQUICC MII Bus: probed
>Freescale PowerQUICC MII Bus: probed
>
>If you need any more information please tell me.
>

Hi Michael,

It looks like even we are enabling only single tx queue, some how it is
trying to pick up tx queue 66. 

Can you please let me know what is your test setup and, please give me
the location from where you cloned this kernel. 
Can you also share the dts file you were using ?

--

Thanks
Sandeep 
