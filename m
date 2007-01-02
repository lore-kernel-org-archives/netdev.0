From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Tue, 2 Jan 2007 15:35:39 -0800
Message-ID: <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com>
References: <4599E6D5.6050207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jarkao2@o2.pl, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:40086 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbXABXft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 18:35:49 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l02NZhvj024057
	for <netdev@vger.kernel.org>; Tue, 2 Jan 2007 18:35:43 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l02NZhcD531818
	for <netdev@vger.kernel.org>; Tue, 2 Jan 2007 16:35:43 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l02NZgQO017030
	for <netdev@vger.kernel.org>; Tue, 2 Jan 2007 16:35:42 -0700
In-Reply-To: <4599E6D5.6050207@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've looked at this a little too -- it'd be nice to know who holds
the write lock.

I see ip_mc_destroy_dev() is bouncing through the lock for
each multicast address, though it starts at the beginning of
the list each time. I don't see a problem with it, but it'd be
simpler if it acquired the write lock once, grabbed and nulled
the list, released the lock and then called igmp_group_dropped()
& ip_ma_put() on each address from the local list copy.

Are you destroying/creating interfaces or doing a lot of multicasting at
the time? How many group memberships do you have?

                                        +-DLS

