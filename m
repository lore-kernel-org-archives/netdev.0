From: Patrick McHardy <kaber@trash.net>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Sat, 05 Mar 2005 17:08:47 +0100
Message-ID: <4229D98F.9010008@trash.net>
References: <20050305141225.GA5180@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, leo@yuriev.ru
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050305141225.GA5180@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> ----- Forwarded message from Leo Yuriev <leo@yuriev.ru> -----
> 
> From: Leo Yuriev <leo@yuriev.ru>
> To: Lennert Buytenhek <buytenh@gnu.org>,
> 	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: linux-kernel@vger.kernel.org
> Subject: [PATCH] ethernet-bridge: update skb->priority in case forwarded frame has VLAN-header
> 
> Kernel 2.6 (2.6.11)
> 
> When ethernet-bridge forward a packet and such ethernet-frame has
> VLAN-tag, bridge should update skb->prioriry for properly QoS
> handling.
> 
> This small patch does this. Currently vlan_TCI-priority directly
> mapped to skb->priority, but this looks enough.
> 
> Patch-by: Leo Yuriev <leo@yuriev.ru>

It needs to verify the tag is present and accessible using
pskb_may_pull(). But I think an ebtables target similar to the iptables
CLASSIFY target is a better place for this. It could allow setting
skb->priority to an arbitary value or derive it from vlan priority or IP
tos.

Regards
Patrick
