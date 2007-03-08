From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100 patch)
Date: Thu, 08 Mar 2007 15:04:05 -0800
Message-ID: <23552.1173395045@death>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu> <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu> <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:60038 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030861AbXCHXEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 18:04:12 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l28N49XY005499
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 18:04:09 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l28N48Xg301306
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 18:04:08 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l28N48we022746
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 18:04:08 -0500
In-reply-to: <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Stromsoe <cbs@cts.ucla.edu> wrote:

>It's active-backup.  Testing with the same setup and e100 works fine. I've
>done a few tests without the bonding module, using the dual-port
>separately.

	Somebody else a couple of weeks ago was having similar issues
running bonding with skge (in 802.3ad mode, in his case) that also
vanished with different hardware.  I don't have any skge hardware, so I
can't test it here.  His problem was a failure in 802.3ad negotiation,
not a system lockup, though.

	If you're running active-backup and not using the ARP monitor
(arp_interval), then I'm not aware of any possible locking problems in
bonding for the kernel version you reference (2.6.20.1).

>1) ip link set mtu 9000 eth2  <-- eth2 is no longer responsive
>   ip link set mtu 1500 eth2  <-- eth2 remains unresponsive
>
>2) ifup eth2
>   ifdown eth2
>
>   perl -pi -e 's/eth2/eth3/' /etc/network/interfaces
>
>   ifup eth3   <--  locks up here

	This would seem to suggest a problem with skge itself, although
there might be some other interaction with bonding that causes the
problems for that case.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
