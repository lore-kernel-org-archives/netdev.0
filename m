From: Ying Xue <ying.xue@windriver.com>
Subject: Re: skbs delivered to 'wrong' packet_type handler
Date: Thu, 8 Aug 2013 10:21:24 +0800
Message-ID: <520300A4.10909@windriver.com>
References: <20130807130856.GI3165@eerihug-hybrid.rnd.ki.sw.ericsson.se> <1375883743.4004.26.camel@edumazet-glaptop> <20130807155746.GA16408@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.windriver.com ([128.224.252.3]:61420 "EHLO
	mail7.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3HHEID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 00:08:03 -0400
In-Reply-To: <20130807155746.GA16408@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 11:57 PM, Erik Hugne wrote:
> On Wed, Aug 07, 2013 at 06:55:43AM -0700, Eric Dumazet wrote:
>> Its not ignored, quite the contrary if you look at the code :
>>
>> vi +3595 net/core/dev.c
>>
>>         type = skb->protocol;
>>         list_for_each_entry_rcu(ptype,
>>                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>>                 if (ptype->type == type &&
>>                     (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
>>                      ptype->dev == orig_dev)) {
>>                         if (pt_prev)
>>                                 ret = deliver_skb(skb, pt_prev, orig_dev);
>>                         pt_prev = ptype;
>>                 }
>>         }
>>
>>
>> pkt->dev being set is only meaningful for packet sockets.
>>
>> Protocols themselves should not care. If they want to care, they must
>> add their own checks.
>>
>> Socket API has SO_BINDTODEVICE for this purpose.
>> IP layer has RP filtering.
>>
>> A protocol should register a single ptype with NULL dev.
>>
> 
> Very well, we'll have to fix the protocol registration and add appropriate 
> checks in TIPC then.

Currently the usage of what TIPC registers its protocol handler into
networking device is totally wrong because af_packet_priv in packet_type
should be only owned by AF_PACKET socket as well as ptype->dev is set
with a network device. But I am sure the patch in below link can
definitely fix your met issue although it's not a final version to be
submitted net-next:

http://permalink.gmane.org/gmane.network.tipc.general/4159


Regards,
Ying

> But i fail to understand why a handler registered on the native device needs 
> to get the packets destined to a child vlan device (the ptype->dev == orig_dev 
> check).
> 
> //E
> 
> 
> 
