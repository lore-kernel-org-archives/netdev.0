From: Ben Greear <greearb@candelatech.com>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Sat, 05 Mar 2005 11:44:33 -0800
Message-ID: <422A0C21.3050709@candelatech.com>
References: <20050305141225.GA5180@xi.wantstofly.org> <4229D98F.9010008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com, leo@yuriev.ru
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4229D98F.9010008@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Lennert Buytenhek wrote:
> 
>> ----- Forwarded message from Leo Yuriev <leo@yuriev.ru> -----
>>
>> From: Leo Yuriev <leo@yuriev.ru>
>> To: Lennert Buytenhek <buytenh@gnu.org>,
>>     Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: linux-kernel@vger.kernel.org
>> Subject: [PATCH] ethernet-bridge: update skb->priority in case 
>> forwarded frame has VLAN-header
>>
>> Kernel 2.6 (2.6.11)
>>
>> When ethernet-bridge forward a packet and such ethernet-frame has
>> VLAN-tag, bridge should update skb->prioriry for properly QoS
>> handling.
>>
>> This small patch does this. Currently vlan_TCI-priority directly
>> mapped to skb->priority, but this looks enough.
>>
>> Patch-by: Leo Yuriev <leo@yuriev.ru>
> 
> 
> It needs to verify the tag is present and accessible using
> pskb_may_pull(). But I think an ebtables target similar to the iptables
> CLASSIFY target is a better place for this. It could allow setting
> skb->priority to an arbitary value or derive it from vlan priority or IP
> tos.

The VLAN code has it's own (user-configurable) mapping from skb->priority to .1q priority,
and .1q priority to skb->priority.  You might want to clone or somehow
use the .1q mapping logic to allow something other than just a straight
.1q -> skb->priority mapping.

Ben

> 
> Regards
> Patrick
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
