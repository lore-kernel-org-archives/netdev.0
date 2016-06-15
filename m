From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Wed, 15 Jun 2016 15:03:39 +0200
Message-ID: <42afc113-d6b1-e289-b4ea-5a83d10d7b19@stressinduktion.org>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
 <20160531.113913.1477085966766110028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, alan.davey@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50628 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753154AbcFONDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 09:03:42 -0400
In-Reply-To: <20160531.113913.1477085966766110028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.05.2016 20:39, David Miller wrote:
> From: Alan Davey <alan.davey@metaswitch.com>
> Date: Mon, 23 May 2016 15:23:45 +0100
> 
>> One of the bugs documented in the raw(7) man page is as follows: When the
>> IP_HDRINCL option is set, datagrams will not be fragmented and are limited to
>> the interface MTU.
>>
>> This patch fixes the bug by removing the check for "length > rt->dst.dev->mtu"
>> in raw_send_hdrinc() (net/ipv4/raw.c).  Datagrams are no longer limited to the
>> interface MTU size if the IP_HDRINCL option is set, but are fragmented, if
>> necessary, in the same way as all other datagrams.
>>
>> Signed-off-by: Alan Davey <alan.davey@metaswitch.com>
> 
> This is not a bug, it's a feature and it's how RAW ipv4 sockets have behaved
> for two decades.
> 
> If the user wants to use hdr inclusion, he can send multiple frames and set
> the fragmentation bits appropriately.

Actually this is difficult, as only the kernel is in control of the
IP_ID generator and it should never leak its state to user space.

The probability of IP_ID collisions would increase drastically because
of this, even imagine different programs doing so concurrently.

Basically those checks are pretty much unnecessary anyway, if we set raw
sockets by default into inet->pmtudisc IPPMTUDISC_DO mode, so a user can
easily control the fragmentation on a raw socket themselves based on
already provided infrastructure.

Bye,
Hannes
