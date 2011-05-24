From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 07:58:37 +0200
Message-ID: <20110524055836.GA2955@psychotron>
References: <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
 <4DD97A44.2020708@candelatech.com>
 <m1wrhigy37.fsf@fess.ebiederm.org>
 <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
 <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com>
 <m1ei3qdwa6.fsf@fess.ebiederm.org>
 <BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com>
 <m139k57nzx.fsf@fess.ebiederm.org>
 <20110523104339.GA2769@psychotron>
 <4DDAB9FC.8050207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112Ab1EXF7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 01:59:35 -0400
Content-Disposition: inline
In-Reply-To: <4DDAB9FC.8050207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 23, 2011 at 09:48:12PM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 23/05/2011 12:43, Jiri Pirko a =E9crit :
>>Mon, May 23, 2011 at 11:41:22AM CEST, ebiederm@xmission.com wrote:
>>>Changli Gao<xiaosuo@gmail.com>  writes:
>>>
>>>>On Mon, May 23, 2011 at 9:45 AM, Eric W. Biederman
>>>><ebiederm@xmission.com>  wrote:
>>>>>>In another side, is there a specification which defines the
>>>>>>hw-accel-vlan-rx?
>>>>>
>>>>>I don't know.
>>>>>
>>>>>I have just been trying to clean up the mess since some of the
>>>>>hw-accel-vlan code broke my use case, by delivering packets with
>>>>>priority but no vlan (aka vlan 0 packets) twice to my pf_packet so=
ckets.
>>>>>
>>>>
>>>>OK. But if we have decided to simulate the hw-accel-vlan-rx, I thin=
k
>>>>we'd better adjust the place where we put the emulation code. The v=
ery
>>>>beginnings of netif_rx() and neif_receive_skb() are better. Then rp=
s
>>>>can support vlan packets without any change.
>>>
>>>That sounds nice. Patches are welcome.
>>>
>>>In principle it should be doable with some code motion.  I don't thi=
nk
>>>moving vlan_untag earlier constitutes a bug fix.
>>
>>I do not think that is doable. Consider multi tagged packets. The pla=
ce
>>just after "another_round" takes care about that.
>>
>>Btw what's the rationale to move untag to earlier position?
>
>Maybe simply because we try to mimic hw-accel, and hw-accel untagging
>definitely happens before we enter __netif_receive_skb and only
>happens once.
>
>So having software untagging inside the __netif_receive_skb loop looks=
 different.

I understand. But what code prior to current vlan_untag position needs
to see the skb untagged?

>
>	Nicolas.
