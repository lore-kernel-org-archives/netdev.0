From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 14:06:09 -0700
Message-ID: <17839.1307394369@death>
References: <1306273128.8149.1444.camel@tardy> <20110604.132940.2214949964968775365.davem@davemloft.net> <1307380132.8149.2718.camel@tardy> <20110606.122217.2183968212149987796.davem@davemloft.net> <1307390721.8149.2763.camel@tardy>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:53380 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab1FFVGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 17:06:38 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p56L0glA009130
	for <netdev@vger.kernel.org>; Mon, 6 Jun 2011 15:00:42 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p56L6G65135346
	for <netdev@vger.kernel.org>; Mon, 6 Jun 2011 15:06:17 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p56LBQ8Q016475
	for <netdev@vger.kernel.org>; Mon, 6 Jun 2011 15:11:26 -0600
In-reply-to: <1307390721.8149.2763.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> wrote:

>On Mon, 2011-06-06 at 12:22 -0700, David Miller wrote:
>> From: Rick Jones <rick.jones2@hp.com>
>> Date: Mon, 06 Jun 2011 10:08:52 -0700
>> 
>> > Mode-rr bonding reorders TCP segments all the time. 
>> 
>> Oh well, then don't use this if you care about performance at all.
>> And therefore it's not even worth considering for our RPS fragment
>> cache.
>
>Heh - the (or at least a) reason people use mode-rr is to make a single
>(TCP) stream go faster :)  Without buying the next-up NIC speed.

	Right, the common use case for balance-rr (round robin) is to
maximize TCP throughput for one connection, over a set of whatever
network devices are available (or are cheap) by striping that connection
across multiple interfaces.  The tcp_reordering sysctl is set to some
large value so that TCP will deal with the reordering as best it can.

	Since TCP generally won't fragment, I don't see that the RPS
frag cache is going to matter for this usage anyway.

	If somebody out there is using round robin for some UDP-based
application that doesn't care about packet ordering (but might create
fragmented datagrams), I've not heard about it.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
