From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Wrong mac in arp response in bonded interfaces
Date: Wed, 18 Jan 2012 11:47:30 -0800
Message-ID: <12128.1326916050@death>
References: <CANj2EbfW-YP41-=w+qGxfV-QMaBOxtijOKFDUt+o-kLsUbf1ag@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:46644 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab2ARTsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 14:48:10 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 18 Jan 2012 12:48:09 -0700
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B391E3E40063
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 12:47:36 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0IJlajb101100
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 14:47:36 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0IJlZUH012051
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 17:47:35 -0200
In-reply-to: <CANj2EbfW-YP41-=w+qGxfV-QMaBOxtijOKFDUt+o-kLsUbf1ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Chen <simonchennj@gmail.com> wrote:

>Hi all,
>
>Something really weird with interface bonding...
>
>I have eth0 and eth1, with MAC address xx:44 and xx:45. The bonded
>interface chose to use xx:45 as its MAC.
>
>I configured an IP on the bonded interface, and try to ping the
>default gw. The ARP from the server for the .1 is answered by the GW.
>The server then sends out ICMP to the GW. The problem is the GW is not
>responding to the ping.

	How much real time is elapsing between the setting up of the
bond, and this ping test?  What are the slaves set up as prior to the
bond being established?  In particular, is one of them (the :44)
assigned the IP address that the bond ends up using?

>I then logged onto the GW (a switch) - apparently, the ARP table on
>the GW shows that my server's IP is associated with xx:44 MAC address.
>So, actually the GW is responding the ICMP, just to the wrong MAC
>dest.
>
>Any idea how the xx:44 MAC somehow polluted the ARP table on my GW?
>How can I make sure my server always sends out packets with xx:45 MAC
>via the bonded interface?

	My first suspicion is that a stale ARP entry on the switch is
hanging around for the :44 MAC address from before the bond was
established on the host.  If you clear the switch's ARP table, does the
problem correct itself or happen again?

	The other possibility that comes to mind is that you're using
balance-alb mode, in which case I suspect what you're seeing is normal
behavior.  The alb mode "assigns" peers to particular slaves of the bond
by sending them tailored ARP messages bearing the MAC of one of the
slaves, and each slave participates on the network under its own MAC
address (I'm simplifying a bit here, but that's basically how it works).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
