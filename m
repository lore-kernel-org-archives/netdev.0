From: Amidu Sila <amidu@eguitel.com>
Subject: Re: [Bridge] [PATCH RFC 0/7] Non-promisc bidge ports support
Date: Thu, 27 Feb 2014 08:54:16 +0000
Message-ID: <530EFD38.5030501@eguitel.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>	<530E7FE1.5060705@mojatatu.com> <530EB313.7090400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, mst@redhat.com
To: vyasevic@redhat.com, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.eguitel.net ([216.147.159.92]:51777 "EHLO
	mail.eguitel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaB0JB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 04:01:29 -0500
In-Reply-To: <530EB313.7090400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please, unsubscribe me.
Regards
Amidu Sila

On 2/27/14, 03:37 AM, Vlad Yasevich wrote:
> On 02/26/2014 06:59 PM, Jamal Hadi Salim wrote:
>> On 02/26/14 10:18, Vlad Yasevich wrote:
>>> This patch series is a complete re-design and re-implementation of
>>> prior attempts to support non-promiscuous bridge ports.
>>>
>>> The basic design is as follows.  The bridge keeps track of
>>> all the ports that flood packets to unknown destinations.  If
>>> the flooding is disabled on the port, to get traffic to flow
>>> through, user/management would need to add an fdb describing
>>> such traffic.  When such fdb is added, we save the address
>>> to bridge private hardware address list.
>> Entering the addresses in the uc list on other bridgeports seems
>> reasonable for the scenario described.
>> But would it _also_ need to be added to the fdb of the bridge?
>> i.e how does the bridge (if the packet was to be handed to it)
>> know where to forward?
> The fdb described here is actually added to the bridge.  In the case
> when we are turning promiscuous mode off on a port, we program the
> address from the fdb down to the port uc list as well.  This allows
> the bridge to continue receiving traffic destined for this address even
> though the port is not in promiscuous mode.
>
>> BTW: on the comment that flooding off implies learning off: I would like
>> to be able to turn off flooding on a specific bridge port but
>> still want to learn from it. I dont think those two are mutually
>> exclusive.
> No they are not, but it does lead to some very interesting traffic
> hang-ups that I've experienced first hand.  Everything works great
> in the beginning.  However, if you go idle for a long enough period
> that the fdb times out, re-establishing the connection take a rather
> long time due to unicast ARPs being dropped by the bridge.  You end
> up waiting until arp fails and switches to broadcast to restore the
> connection.  So, this mode isn't really recommended.  Nothing currently
> forbids it however.
>
> -vlad
>> cheers,
>> jamal
