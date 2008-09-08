From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [ INFO: inconsistent lock state ]  2.6.25.10
Date: Mon, 8 Sep 2008 11:32:18 +0000
Message-ID: <20080908113218.GA6169@ff.dom.local>
References: <48C3CEE0.6040308@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:25502 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbYIHLc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 07:32:26 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1450169fgg.17
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 04:32:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48C3CEE0.6040308@upmc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-09-2008 14:53, Bernard Pidoux wrote:
> Hi,
> 
> I observed this message recently on a system with acpi=off for
> the bios is quite old.
> 
> Apparently listen application and console are involved.
> 
> Is there anything I can try to resolve this situation ,
> 
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.25.10-patched-ax25 #1
> ---------------------------------
> inconsistent {in-softirq-W} -> {softirq-on-W} usage.
> listen/7202 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (_xmit_ETHER){-+..}, at: [<c0262f08>] netpoll_send_skb+0x118/0x180

Hi Bernard,

These warnings usually mean there is some local_irq_disable/enable()
instead of local_irq_save/restore() etc. on the xmit path (maybe in a
network driver used for netconsole). Anyway, as usual, it would be
nice to test it with some more current kernel, and if it's still
there, add some info about this driver and additional patches.

Thanks,
Jarek P.
