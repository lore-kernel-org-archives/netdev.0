From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Thu, 21 Jul 2011 15:01:07 -0700 (PDT)
Message-ID: <20110721.150107.25773992475689131.davem@davemloft.net>
References: <20110720020737.GB2692@neilslaptop.think-freely.org>
	<1311135855.3113.66.camel@edumazet-laptop>
	<20110720151827.GD12349@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, greearb@candelatech.com, jpirko@redhat.com,
	netdev@vger.kernel.org, adobriyan@gmail.com,
	robert.olsson@its.uu.se
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab1GUWDc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:03:32 -0400
In-Reply-To: <20110720151827.GD12349@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 20 Jul 2011 11:18:27 -0400

> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
>> Le mardi 19 juillet 2011 =E0 22:07 -0400, Neil Horman a =E9crit :
>> > >=20
>> > I think this is a good idea.  It lets pktgen dynamically make the =
clone/share
>> > decision dynamically and only impacts performance for those system=
s.
>> >=20
>>=20
>> Just let pktgen refuse to use clone_skb command for these devices.
>>=20
> copy that, This is by no means final, but what do you think of this? =
 If its
> agreeable to you, Ben, et al. I can add this to my local tree and sta=
rt auditing
> all the drivers that may need to have the flag set.

I think there is a much simpler solution.

Set a flag in the SKB when pktgen does SKB sharing.

In dev_queue_xmit() (or perhaps, dev_hard_start_xmit()), check the flag
and if it's set then we copy the SKB.

If this works, then we fix the crash and no driver changes are
necessary both now and in the future.
