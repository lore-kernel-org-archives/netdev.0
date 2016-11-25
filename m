From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Thu, 24 Nov 2016 19:54:04 -0800
Message-ID: <1480046044.8455.529.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161125120947.142c3af5@canb.auug.org.au>
         <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
         <20161125134520.68ca0969@canb.auug.org.au>
         <1480042888.8455.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161125140938.24538f97@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eli Cooper <elicooper@gmx.com>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35503 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbcKYECc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 23:02:32 -0500
Received: by mail-pg0-f47.google.com with SMTP id p66so24993532pga.2
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 20:02:30 -0800 (PST)
In-Reply-To: <20161125140938.24538f97@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 14:09 +1100, Stephen Rothwell wrote:
> Hi Eric,
> 
> On Thu, 24 Nov 2016 19:01:28 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Since I do not have this problem at all on my hosts, it could be a buggy
> > ethernet driver.
> > 
> > Could you share what NIC card and driver you are using ?
> 
> 
> # uname -a
> Linux bilbo 4.7.0-1-amd64 #1 SMP Debian 4.7.8-1 (2016-10-19) x86_64 GNU/Linux
> 
> # lspci | grep -i net
> 03:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Connection (rev 03)
> 04:00.0 Ethernet controller: Intel Corporation I210 Gigabit Network Connection (rev 03)
> 
> from boot dmesg:
> 
> [    7.573725] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.3.0-k
> [    7.573726] igb: Copyright (c) 2007-2014 Intel Corporation.
> [    7.752918] igb 0000:03:00.0: added PHC on eth0
> [    7.752925] igb 0000:03:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    7.752927] igb 0000:03:00.0: eth0: (PCIe:2.5Gb/s:Width x1) 00:1e:67:9f:d4:24
> [    7.753460] igb 0000:03:00.0: eth0: PBA No: 102100-000
> [    7.753460] igb 0000:03:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> [    7.902433] igb 0000:04:00.0: added PHC on eth1
> [    7.902434] igb 0000:04:00.0: Intel(R) Gigabit Ethernet Network Connection
> [    7.902435] igb 0000:04:00.0: eth1: (PCIe:2.5Gb/s:Width x1) 00:1e:67:9f:d4:25
> [    7.902484] igb 0000:04:00.0: eth1: PBA No: 102100-000
> [    7.902485] igb 0000:04:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> [   19.753325] igb 0000:03:00.0 eth0: igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
> 

Could you now report : 

ethtool -k eth0

Thanks
