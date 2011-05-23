From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 02:41:22 -0700
Message-ID: <m139k57nzx.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>
	<BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
	<BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com>
	<m1ei3qdwa6.fsf@fess.ebiederm.org>
	<BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51524 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab1EWJl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 05:41:26 -0400
In-Reply-To: <BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com> (Changli
	Gao's message of "Mon, 23 May 2011 10:14:02 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:

> On Mon, May 23, 2011 at 9:45 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>> In another side, is there a specification which defines the
>>> hw-accel-vlan-rx?
>>
>> I don't know.
>>
>> I have just been trying to clean up the mess since some of the
>> hw-accel-vlan code broke my use case, by delivering packets with
>> priority but no vlan (aka vlan 0 packets) twice to my pf_packet sockets.
>>
>
> OK. But if we have decided to simulate the hw-accel-vlan-rx, I think
> we'd better adjust the place where we put the emulation code. The very
> beginnings of netif_rx() and neif_receive_skb() are better. Then rps
> can support vlan packets without any change.

That sounds nice. Patches are welcome.

In principle it should be doable with some code motion.  I don't think
moving vlan_untag earlier constitutes a bug fix.

In my investigation earlier I found a non-trivial number of paths into
__netif_receive_skb.  So it was not clear to me in the slightest how to
move the check earlier without modifying every networking driver and a
few other pieces of code.

Why should receive packet steering be affected by vlan tags at all?

Eric

