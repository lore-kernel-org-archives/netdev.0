From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 13:16:02 -0700
Message-ID: <4ADE1A82.30108@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40404 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbZJTUQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 16:16:04 -0400
In-Reply-To: <4ADE0770.8060708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2009 11:54 AM, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
>
>> David, we are changing skb->mapping while transmitting it...
>>
>> So yes, it can break pktgen if its skbs are cloned.
>>
>> Maybe pktgen should call skb_record_rx_queue() instead of skb_set_qu=
eue_mapping()
>>
>> Or maybe we should avoid this +/- 1 thing we do in skb_record_rx_que=
ue(), since
>> we use same skb field for recording rx_queue or tx_queue :(
>>
>
> A possible fix would be :

I tried your patch.  It's not crashing, but the link is bouncing around=
:

Oct 20 13:13:34 localhost kernel: ixgbe 0000:05:00.0: master disable ti=
med out
Oct 20 13:13:35 localhost kernel: ixgbe 0000:05:00.0: master disable ti=
med out
Oct 20 13:13:35 localhost kernel: ixgbe 0000:05:00.0: master disable ti=
med out
=2E..

Oct 20 13:14:06 localhost kernel: ixgbe 0000:05:00.0: master disable ti=
med out
Oct 20 13:14:06 localhost kernel: ixgbe: eth9 NIC Link is Down
Oct 20 13:14:06 localhost kernel: ixgbe: eth9 NIC Link is Up 10 Gbps, F=
low Control: RX/TX
Oct 20 13:14:09 localhost kernel: ixgbe: eth8 NIC Link is Up 10 Gbps, F=
low Control: RX/TX
Oct 20 13:14:12 localhost kernel: ixgbe 0000:05:00.1: master disable ti=
med out
Oct 20 13:14:15 localhost kernel: ixgbe: eth9 NIC Link is Up 10 Gbps, F=
low Control: RX/TX
Oct 20 13:14:19 localhost kernel: ixgbe: eth9 NIC Link is Down
Oct 20 13:14:19 localhost kernel: ixgbe 0000:05:00.0: master disable ti=
med out


I'm not sure if this is another weirdness in my system or something
else...

Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

