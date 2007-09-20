From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] ifb and ppp
Date: Thu, 20 Sep 2007 13:55:06 +0200
Message-ID: <46F25F9A.7010007@trash.net>
References: <200709191417.43768.mail@frithjof-hammer.de>	<46F11E76.8030202@trash.net> <200709192342.03646.mail@frithjof-hammer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>,
	jamal <hadi@cyberus.ca>
To: Frithjof Hammer <mail@frithjof-hammer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35845 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXITMCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:02:30 -0400
In-Reply-To: <200709192342.03646.mail@frithjof-hammer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please keep netdev and myself CCed.

Frithjof Hammer wrote:
>>Does this patch help?
> 
> 
> A further examiniation:
> [...]
> printk ("fri: mein type %x\n",dev->type);
>                 switch (dev->type) {
> 
> [...]
> shows this:
> 
> root@router:/usr/src/linux-source-2.6.21# dmesg | grep fri
> fri: mein type 1
> 
> that is defined as ARPHRD_ETHER in include/linux/if_arp.h.
> 
> As far as i understand this means, that my ppp0 device is recognized as 
> Ethernetinterface.
> 
> Any further help/ideas?


I misread the code, the device it looks at in tcf_mirred_init is
the target device (ifb). So what it does is check whether the
target device wants a link layer header and if it does restores
the one from the source device. So currently it seems impossible
to get rid of the PPP(oE) header.

Jamal, is that how its supposed to work?
