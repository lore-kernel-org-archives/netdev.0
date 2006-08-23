From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast group memberships purge on interface delete
Date: Wed, 23 Aug 2006 11:51:48 -0700
Message-ID: <OF77A66489.EF09BE53-ON882571D3.00666BB7-882571D3.00679F2F@us.ibm.com>
References: <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:7090 "EHLO e32.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S964864AbWHWSvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 14:51:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7NIprjD012374
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 14:51:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7NIpqbv263796
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 12:51:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7NIpq2Q031910
	for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 12:51:52 -0600
In-Reply-To: <021e01c6c6a4$6e7845f0$2303a8c0@mruzicka>
To: Michal Ruzicka <michal.ruzicka@comstar.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal,

> My question/suggestion:
> Would it feasible to drop the relevant entries from sockets' multicast 
> membership lists on the interface
> delete?

        Yes, I think this is needed. The original BSD code didn't have 
this
problem because it didn't support removal of a device. I wondered for a
while whether an app should care whether the device was removed or not on
a "leave", but I think it probably should get ENODEV in that case, just
as it would for any invalid interface index, whether or not it used to
be valid. So, simply removing the memberships and filters on device
destroy looks right to me.

        I'm not sure that maintaining a per-device socket list is 
necessary,
since removal of a device is relatively unusual, and that may make locking
and reference counting more complicated (maybe not). Probably a simple
search of all UDP sockets with non-null multicast lists and matching
interface index is sufficient.
        IGMPv3 is there fully, and uses a more efficient way of tracking
interface and socket filter intersections and unions than the "obvious"
way as suggested by the RFC. I don't think it is affected either way by
this.

        I'll either do or review a patch for this, depending on who
gets to it first. :-)

                                                                +-DLS

