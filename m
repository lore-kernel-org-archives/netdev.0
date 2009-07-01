From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default configurable
Date: Tue, 30 Jun 2009 21:14:40 -0700
Message-ID: <4A4AE2B0.7060909@candelatech.com>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr> <20090701011528.GA28676@gondor.apana.org.au> <alpine.LSU.2.00.0907010535170.6438@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58572 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbZGAEsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 00:48:01 -0400
In-Reply-To: <alpine.LSU.2.00.0907010535170.6438@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Wednesday 2009-07-01 03:15, Herbert Xu wrote:
>   
>> On Tue, Jun 30, 2009 at 10:16:35PM +0200, Jan Engelhardt wrote:
>>     
>>> It makes sense absolutely. Consider:
>>>
>>> * packet enters bridge
>>> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
>>> * (connection tracking entry is set up)
>>> * let bridging decision be "local delivery"
>>>       
>> No, my question is does it ever make sense to use conntrack as
>> part of bridge netfilter.  That is, do you ever want to test it
>> in your rules that are run as part of bridge netfilter.
>>     
>
> There is the possibility that some users have -m conntrack in their
> mangle table in the PREROUTING chain. However, I am pretty sure that
> if there are such users, they do it because of the layer-3/4/5/7 part
> and not care about bridge so much.
>
>   
>> conntrack is inherently a security hole when used as part of
>> bridging, because it ignores the Ethernet header so two unrelated
>> connections can be tracked as one.
>>     
>
> On secondary thought, one could also argue that because conntrack 
> ignores the interface, two unrelated connections happening to be routed 
> through the same machine(*) are tracked as one, too.
>   
I had a similar problem while trying to implement virtual routers using 
different
routing tables and something like 'veth' to connect them.

My solution was to add a 'mark' field to the netdevice and allow 
user-space to set
the mark on the device.  This mark was included as part of the 
connection identifier.

The mark is set before the pkt hits the bridge code on ingress, so a pkt 
entering from
eth1 can get a different connection hash from a pkt entering eth2, even 
if all other
data in the packet is the same.

I'll dig it out of my monster patch if something like this is deemed 
useful upstream.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


