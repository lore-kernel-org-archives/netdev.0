From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Sun, 22 May 2011 14:04:04 -0700
Message-ID: <4DD97A44.2020708@candelatech.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>	<20110412.141645.112604563.davem@davemloft.net>	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>	<20110521072925.GA2588@jirka.orion>	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>	<4DD7BB61.9050200@gmail.com>	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>	<m17h9jp7js.fsf@fess.ebiederm.org>	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com> <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>,
	=?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44172 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab1EVVEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 17:04:36 -0400
In-Reply-To: <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2011 12:39 PM, Eric W. Biederman wrote:
>
> Simplify the vlan handling code by not supporing clearing of
> VLAN_FLAG_REORDER_HDR.  Which means we always make the vlan handling
> code strip the vlan header from the packets, and always insert the vlan
> header when transmitting packets.
>
> Not stripping the vlan header has alwasy been broken in combination with
> vlan hardware accelleration.  Now that we are making everything look
> like accelerated vlan handling not stripping the vlan header is always
> broken.
>
> I don't think anyone actually cares so simply stop supporting the broken
> case.

I've lost track of the VLAN code a bit.  Is there any documentation
somewhere about what happens in these various cases:

*  Open a raw packet socket on eth0.
   *  Do we get tagged VLAN packets?  (I'd expect yes.)
   *  If we sent a tagged VLAN packet, it's sent without modification?  (I'd expect yes.)
   **  Without "yes" to the two above, one cannot do user-space bridging properly.

*  Open a raw packet socket on VLAN eth0.5
   *  Do we get tagged VLAN packets?  (I'd expect no.)
   *  If we send an un-tagged packet, I expect it would be tagged?
   *  What if we sent a tagged packet with same VID?
   *  With different VID?

Many years ago we supported the REORDER, but we suggested disabling
it for most users because it was a performance drag.  Funny that now
it seems to be the opposite!

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
