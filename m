From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit
 methods
Date: Thu, 21 Jul 2011 15:14:32 -0700
Message-ID: <4E28A4C8.8040707@candelatech.com>
References: <20110720020737.GB2692@neilslaptop.think-freely.org>	<1311135855.3113.66.camel@edumazet-laptop>	<20110720151827.GD12349@hmsreliant.think-freely.org> <20110721.150107.25773992475689131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, adobriyan@gmail.com,
	robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57378 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072Ab1GUWOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:14:53 -0400
In-Reply-To: <20110721.150107.25773992475689131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 03:01 PM, David Miller wrote:
> From: Neil Horman<nhorman@tuxdriver.com>
> Date: Wed, 20 Jul 2011 11:18:27 -0400
>
>> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
>>> Le mardi 19 juillet 2011 =E0 22:07 -0400, Neil Horman a =E9crit :
>>>>>
>>>> I think this is a good idea.  It lets pktgen dynamically make the =
clone/share
>>>> decision dynamically and only impacts performance for those system=
s.
>>>>
>>>
>>> Just let pktgen refuse to use clone_skb command for these devices.
>>>
>> copy that, This is by no means final, but what do you think of this?=
  If its
>> agreeable to you, Ben, et al. I can add this to my local tree and st=
art auditing
>> all the drivers that may need to have the flag set.
>
> I think there is a much simpler solution.
>
> Set a flag in the SKB when pktgen does SKB sharing.
>
> In dev_queue_xmit() (or perhaps, dev_hard_start_xmit()), check the fl=
ag
> and if it's set then we copy the SKB.
>
> If this works, then we fix the crash and no driver changes are
> necessary both now and in the future.

Doesn't that make clone-skb in pktgen much less efficient
in all cases?

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

