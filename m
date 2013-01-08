From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: balance-alb and arp-reply stomping
Date: Tue, 08 Jan 2013 09:14:39 -0800
Message-ID: <31979.1357665279@death.nxdomain>
References: <CAK8PzV=GN0+txo=ixnKGGUXEeJMfd8=Ce=bSReg_oJXScbs79g@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: "Matthew O'Connor" <liquidhorse@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42126 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756231Ab3AHRPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 12:15:16 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 8 Jan 2013 10:15:15 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 821F719D805F
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2013 10:15:08 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r08HEl4K077782
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2013 10:14:55 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r08HGtGq029696
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2013 10:16:56 -0700
In-reply-to: <CAK8PzV=GN0+txo=ixnKGGUXEeJMfd8=Ce=bSReg_oJXScbs79g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew O'Connor <liquidhorse@gmail.com> wrote:

>Hi!  I've encountered what appears to be a known "issue" with
>balance-alb, whereby when a bond configured thus is put into a bridge
>with virtual ethernet adapters, on reply to arp requests the bond
>appears to "stomp" the MAC of the outgoing replies with one of its own
>adapters' MACs.  The consequence seems to be intermittent
>connectivity, easily witnessed by ping-loss early in a virtual
>adapter's life.  Checking the ARP cache on another machine shows that
>the virtual adapter's MAC has been replaced with one of the bond
>slaves'.  Other bonding modes do not exhibit this behavior.
>
>I was wondering if this is something that had been brought up before
>for fixing, and whether or not you would accept a patch if an
>appropriate fix was implemented?  My naive understanding would suggest
>checking the outgoing reply against a table of known slaves, and if
>the MAC did not exist there then map it to a slave and transmit the
>reply unmodified.

	This should be fixed in current kernels (to have balanace-alb
mode not modify ARPs that do not originate locally); I see the patch in
the 3.8-rc2 source, but not in the linux-3.7.1 source.

	You could apply the patch to an older kernel, it's pretty
simple.  The patch itself can be found here:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=patch;h=567b871e503316b0927e54a3d7c86d50b722d955

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
