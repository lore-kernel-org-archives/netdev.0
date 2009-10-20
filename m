From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 16:17:16 -0700
Message-ID: <4ADE44FC.4030406@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com> <4ADE3253.10302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55611 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbZJTXRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 19:17:17 -0400
In-Reply-To: <4ADE3253.10302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2009 02:57 PM, Eric Dumazet wrote:
> Ben Greear a =E9crit :
>> That's definitely a nasty little issue.  Using skb_set_queue_mapping
>> in pktgen makes it run for me, but may just be getting lucky with th=
e
>> mac-vlan interfaces which will do the dev_queue_xmit (but, I don't s=
o much
>> care exactly what queue is used as long as things don't crash and th=
e
>> link doesn't reset).
>>
>> Don't worry about a quick patch on my account.  I seem to have it wo=
rking
>> to at least some degree (no funny crashes, no link watchdog timeouts=
).
>>
>
> Could you try following patch ?
>
> This makes queue_mapping invariant if set in range [0 ... real_num_tx=
_queues-1]

Yes, that runs w/out causing link resets and without crashes (just test=
ed it for
a few minutes).

Interestingly, the pkts sent by pktgen on the mac-vlans end up in
tx-queues that match processor ID, even though I'm on .31 where mac-vla=
ns
have only one tx-queue and pktgen is setting the queue to 0 in the skb
(per your previous patch).

Must be something somewhere doing the mapping of processor ids to txqs.

I'll try to figure this out this evening or tomorrow.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

