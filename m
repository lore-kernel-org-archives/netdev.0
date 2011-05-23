From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 12:43:40 +0200
Message-ID: <20110523104339.GA2769@psychotron>
References: <m17h9jp7js.fsf@fess.ebiederm.org>
 <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
 <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
 <4DD97A44.2020708@candelatech.com>
 <m1wrhigy37.fsf@fess.ebiederm.org>
 <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
 <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com>
 <m1ei3qdwa6.fsf@fess.ebiederm.org>
 <BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com>
 <m139k57nzx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499Ab1EWKn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2011 06:43:57 -0400
Content-Disposition: inline
In-Reply-To: <m139k57nzx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 23, 2011 at 11:41:22AM CEST, ebiederm@xmission.com wrote:
>Changli Gao <xiaosuo@gmail.com> writes:
>
>> On Mon, May 23, 2011 at 9:45 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>>> In another side, is there a specification which defines the
>>>> hw-accel-vlan-rx?
>>>
>>> I don't know.
>>>
>>> I have just been trying to clean up the mess since some of the
>>> hw-accel-vlan code broke my use case, by delivering packets with
>>> priority but no vlan (aka vlan 0 packets) twice to my pf_packet sockets.
>>>
>>
>> OK. But if we have decided to simulate the hw-accel-vlan-rx, I think
>> we'd better adjust the place where we put the emulation code. The very
>> beginnings of netif_rx() and neif_receive_skb() are better. Then rps
>> can support vlan packets without any change.
>
>That sounds nice. Patches are welcome.
>
>In principle it should be doable with some code motion.  I don't think
>moving vlan_untag earlier constitutes a bug fix.

I do not think that is doable. Consider multi tagged packets. The place
just after "another_round" takes care about that.

Btw what's the rationale to move untag to earlier position?

>
>In my investigation earlier I found a non-trivial number of paths into
>__netif_receive_skb.  So it was not clear to me in the slightest how to
>move the check earlier without modifying every networking driver and a
>few other pieces of code.
>
>Why should receive packet steering be affected by vlan tags at all?
>
>Eric
>
