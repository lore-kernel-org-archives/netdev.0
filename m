From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN] vlan_skb_recv
Date: Wed, 20 Feb 2008 13:27:10 +0100
Message-ID: <47BC1C9E.5050104@trash.net>
References: <200802122000.m1CK056H002237@ns2.lanforge.com> <E06E3B7BBC07864CADE892DAF1EB0FBD04E669E1@NT-SJCA-0752.brcm.ad.broadcom.com> <47B31B96.7010801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux 802.1Q VLAN" <vlan@candelatech.com>,
	Stephen Anderson <smanders@broadcom.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:5305 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbYBTM1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:27:32 -0500
In-Reply-To: <47B31B96.7010801@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Stephen Anderson wrote:
>> Hello,
>>
>> To help increase throughput and bypass the backlog queue, I changed the
>> netif_rx() to netif_receive_skb() in vlan_skb_recv().  What's the
>> argument for using netif_rx() other than legacy maintenance?  At this
>> point, interrupt context should not be an issue.  Layer 2 performance
>> has been a big focus in my area of development.


I guess the only point is to reduce stack usage. Its probably not
a problem with only VLAN, but it might be with further tunnels,
IPsec, ...

>> I'm sure you have seen many attempts to implement a single VLAN aware
>> IVL FDB in the past and I was wondering which attempt do you feel was
>> the best?  Have you ever considered integrating your VLAN support
>> natively into the bridging code base or know of any attempts to do just
>> that?


Without having thought about this much, it seems to me that
it needs to be integrated in the bridge fdb to work properly.

