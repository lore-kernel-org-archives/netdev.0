From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Sun, 22 May 2011 15:38:36 -0700
Message-ID: <m1wrhigy37.fsf@fess.ebiederm.org>
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
	<4DD97A44.2020708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51122 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384Ab1EVWit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 18:38:49 -0400
In-Reply-To: <4DD97A44.2020708@candelatech.com> (Ben Greear's message of "Sun,
	22 May 2011 14:04:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 05/22/2011 12:39 PM, Eric W. Biederman wrote:
>>
>> Simplify the vlan handling code by not supporing clearing of
>> VLAN_FLAG_REORDER_HDR.  Which means we always make the vlan handling
>> code strip the vlan header from the packets, and always insert the vlan
>> header when transmitting packets.
>>
>> Not stripping the vlan header has alwasy been broken in combination with
>> vlan hardware accelleration.  Now that we are making everything look
>> like accelerated vlan handling not stripping the vlan header is always
>> broken.
>>
>> I don't think anyone actually cares so simply stop supporting the broken
>> case.
>
> I've lost track of the VLAN code a bit.  Is there any documentation
> somewhere about what happens in these various cases:

Other than the code I don't know about documentation.

> *  Open a raw packet socket on eth0.
I assume you mean a pf_packet socket.

>   *  Do we get tagged VLAN packets?  (I'd expect yes.)
yes.

>   *  If we sent a tagged VLAN packet, it's sent without modification?  (I'd expect yes.)
>   **  Without "yes" to the two above, one cannot do user-space bridging properly.

This is sort of.  If you set the PACKET_AUXDATA option and use recv_cmsg
you get the priority and the vlan identifier in the auxdata.

I think that is a pretty horrible answer myself but it has been that way
since sometime mid 2008.  So I'm not immediately prepared to call it
a regression, or a bug.

> *  Open a raw packet socket on VLAN eth0.5
>   *  Do we get tagged VLAN packets?  (I'd expect no.)
No.

>   *  If we send an un-tagged packet, I expect it would be tagged?
Yes.

>   *  What if we sent a tagged packet with same VID?
>   *  With different VID?
The vlan tag is ignored and another vlan tag is added.

> Many years ago we supported the REORDER, but we suggested disabling
> it for most users because it was a performance drag.  Funny that now
> it seems to be the opposite!

Yes it is funny.  I looked in history a while back and what I saw was
that REORDER was always enabled by default and it took some serious
effort to figure out how to get vconfig to disable REORDER. ip doesn't
admit that REORDER can be disabled at all.

Eric
