From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: bug in balance-alb mode (incorrect update-ARP-replie s)
Date: Fri, 26 Jan 2007 15:29:49 -0800
Message-ID: <200701262329.l0QNTo22025513@death.nxdomain.ibm.com>
References: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9BE@nts27.saarstahl.de>
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "JUNG, Christian" <christian.jung@saarstahl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48633 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751768AbXAZX3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 18:29:53 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0QNTq3j019510
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 18:29:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0QNTqgI275018
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 18:29:52 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0QNTphZ008824
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 18:29:51 -0500
In-reply-to: <FA8270F9F8D35946ADDBC0F36E6667CE0175C9BE@nts27.saarstahl.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

JUNG, Christian <christian.jung@saarstahl.com> wrote:

>> Jay Vosburgh <fubar@us.ibm.com> wrote:
>> 
>> 	Is your test occuring on an isolated network, and is there other
>> concurrent network traffic that might be affecting things?
>
>The problem still persists as long as the box is connected to our Ciscos.
>
>I tried to simulate it with a dumb switch with my two boxes connected only.
>But there were no unsolicited ARP-replies anymore.

	I'm using Cisco switches as well.  I don't see the regular,
periodic ARP replies being generated as you describe, but I do see the
bonding driver issuing ARP replies for some or all of the elements of
the rx hashtable when certain events occur (slaves coming on/off line,
ARP requests coming from the local system, ).

>On the Ciscos I sometimes see ARP-replies with a destination MAC of
>00:00:00:00:00:00 (!) from some Linux-boxes which are using bonding.
>Currently I don't have a clue from where they're coming...

	I also saw one of those; I don't know where it came from,
either.

>The boxes are receiving around 200 ARP-replies a minute - so yes, there's
>concurrent network traffic :-)

	Well, I meant other traffic that causes the ARP replies to be
generated (i.e., concurrent traffic with the system).

	There are some other issues with the rx hashtbl that have come
up from my poking around, largely that it never, ever removes an entry
from the table.  After a sufficient number of different clients have
connected, the table will be filled with stale entries.  That's not
necessarily a problem in of itself, but it can lead to pathological
cases wherein regular ARP traffic induces update storms for peers that
are no longer interested.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
