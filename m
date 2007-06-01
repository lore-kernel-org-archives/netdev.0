From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH]: bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 01 Jun 2007 10:30:13 -0700
Message-ID: <9575.1180719013@death>
References: <97949e3e0706010933h6921ca72p9858daa229bcfce6@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: "Laurent Chavey" <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:42111 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760889AbXFARaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 13:30:20 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l51GRqjE007132
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 12:27:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l51HUGAq519690
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 13:30:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l51HUGWw015764
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 13:30:16 -0400
In-reply-to: <97949e3e0706010933h6921ca72p9858daa229bcfce6@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Chavey <chavey@google.com> wrote:

>On 5/31/07, Laurent Chavey <chavey@google.com> wrote:
>> if a host configured with 802.3ad bond mode is connected to a switch
>> that does not support 802.3ad,  then an aggregator is selected as the
>> active aggregator (first link that has carrier in the slave list).
>> This is perfectly fine, since it lets at least one of the link become active.
>> (this was the behavior prior to 2.6.18)
>>
>> In 2.6.18 and above, a new check for the partner mac address was added
>> before an aggregator's carrier is set on. If a host is  configured as
>> previously
>> described,  then no links will become active.
>>
>> is that the intended behavior ?

	Prior to the change in question, the carrier state of the master
device was always on, regardless of the state of the slaves (so even if
things didn't work, bonding would claim to be up).

	My concern specifically was more with failures in negotiation
with 802.3ad capable peers, not for interoperability with non-802.3ad
devices (since bonding can always be run in a non-802.3ad mode).

	This behavior (don't pass traffic if no 802.3ad setup occurs)
also parallels the behavior of the Cisco switches I use to test bonding
(they will not pass traffic across ports of a lacp channel-group if the
802.3ad negotation does not occur), so it seemed appropriate.

	I'm checking the standard to see what it says, but I'm also
curious if this has some real-world impact, or is just something you
happened across?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
