From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Wed, 02 Feb 2011 09:30:02 -0800
Message-ID: <31440.1296667802@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru> <19551.1296268113@death> <4D4833EA.50407@yandex-team.ru>
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:60911 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab1BBRaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 12:30:08 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p12HFoce014650
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:15:50 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p12HU4aO110530
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:30:05 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p12HYdl8001054
	for <netdev@vger.kernel.org>; Wed, 2 Feb 2011 10:34:39 -0700
In-reply-to: <4D4833EA.50407@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oleg V. Ukhno <olegu@yandex-team.ru> wrote:

>On 01/29/2011 05:28 AM, Jay Vosburgh wrote:
>> Oleg V. Ukhno<olegu@yandex-team.ru>  wrote:
>>
>> 	I've thought about this whole thing, and here's what I view as
>> the proper way to do this.
>>
>> 	In my mind, this proposal is two separate pieces:
>>
>> 	First, a piece to make round-robin a selectable hash for
>> xmit_hash_policy.  The documentation for this should follow the pattern
>> of the "layer3+4" hash policy, in particular noting that the new
>> algorithm violates the 802.3ad standard in exciting ways, will result in
>> out of order delivery, and that other 802.3ad implementations may or may
>> not tolerate this.
>>
>> 	Second, a piece to make certain transmitted packets use the
>> source MAC of the sending slave instead of the bond's MAC.  This should
>> be a separate option from the round-robin hash policy.  I'd call it
>> something like "mac_select" with two values: "default" (what we do now)
>> and "slave_src_mac" to use the slave's real MAC for certain types of
>> traffic (I'm open to better names; that's just what I came up with while
>> writing this).  I believe that "certain types" means "everything but
>> ARP," but might be "only IP and IPv6."  Structuring the option in this
>> manner leaves the option open for additional selections in the future,
>> which a simple "on/off" option wouldn't.  This option should probably
>> only affect a subset of modes; I'm thinking anything except balance-tlb
>> or -alb (because they do funky MAC things already) and active-backup (it
>> doesn't balance traffic, and already uses fail_over_mac to control
>> this).  I think this option also needs a whole new section down in the
>> bottom explaining how to exploit it (the "pick special MACs on slaves to
>> trick switch hash" business).
>>
>> 	Comments?
>>
>> 	-J
>>
>Jay,
>As for me splitting my initial proposal into two logically diffent pieces
>is ok, this will provide more flexible configuration.
>Do I understand correctly, that after I rewrite  patch in splitted form,
>as you described above, and enhance documentation it will be /can be
>applied to kernel?

	Yes, although the patches may have to go through a few
revisions.


>Then what should I do: rewrite patch and resubmit it as a new one?

	Yes.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

