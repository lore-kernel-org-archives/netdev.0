From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 20:05:07 -0700
Message-ID: <4ADE7A63.4090404@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com> <4ADE3253.10302@gmail.com> <4ADE44FC.4030406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33468 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbZJUDFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 23:05:09 -0400
In-Reply-To: <4ADE44FC.4030406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 10/20/2009 02:57 PM, Eric Dumazet wrote:
>> Ben Greear a =E9crit :
>>> That's definitely a nasty little issue.  Using skb_set_queue_mappin=
g
>>> in pktgen makes it run for me, but may just be getting lucky with t=
he
>>> mac-vlan interfaces which will do the dev_queue_xmit (but, I don't=20
>>> so much
>>> care exactly what queue is used as long as things don't crash and t=
he
>>> link doesn't reset).
>>>
>>> Don't worry about a quick patch on my account.  I seem to have it=20
>>> working
>>> to at least some degree (no funny crashes, no link watchdog timeout=
s).
>>>
>>
>> Could you try following patch ?
>>
>> This makes queue_mapping invariant if set in range [0 ...=20
>> real_num_tx_queues-1]
>
> Yes, that runs w/out causing link resets and without crashes (just=20
> tested it for
> a few minutes).
>
> Interestingly, the pkts sent by pktgen on the mac-vlans end up in
> tx-queues that match processor ID, even though I'm on .31 where mac-v=
lans
> have only one tx-queue and pktgen is setting the queue to 0 in the sk=
b
> (per your previous patch).
Ok, this is because ixgbe implements the ndo_select_queue, which is=20
called from
dev_pick_tx.

So, as far as I can tell, as long as you are using ixgbe with 82559, it=
=20
doesn't matter what you set
for the queue-map in the skb..it's always over-written.

I don't know if this is a bug or a feature, but it explains the behavio=
r=20
with tx and rx queues
that I saw when using pktgen on mac-vlans...

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>=20
Candela Technologies Inc  http://www.candelatech.com


