From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Tue, 24 Aug 2004 02:45:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412A8FB5.4080700@trash.net>
References: <OF4320C747.75C5E93A-ON88256EF9.00744FBA-88256EF9.00750996@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF4320C747.75C5E93A-ON88256EF9.00744FBA-88256EF9.00750996@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:

>BTW, since some of the frags (esp. the one that triggers the problem)
>are added post-routing, a valid dst is available. It just isn't the first
>frag in the particular scenario.
>
>So, one solution would be to set skb->dst for the head (if NULL)  based
>on a non-null fragment skb->dst. I believe that would prevent the problem
>case without dropping the fragment, since it'll be processed post-routing
>only if one of the frags is.
>  
>
The fragments which jumped from PRE_ROUTING to ip_local_deliver will miss
ip options processing.

>When I was looking at it, I wondered if conntrack really has a need to
>reassemble itself, though. Couldn't it let IP do the reassembling and
>just ignore offset != 0 frags? The offset==0 frags will have enough
>protocol header to identify by port (a requirement for ICMP). But I don't
>know this code well enough to know if conntrack does actually need
>to reassemble for some good reason. Superficially, I wouldn't think
>there'd be a reason for it.
>  
>
The NAT code needs to handle all fragments, so they can't be skipped.
Handling fragments in conntrack and NAT would be possible without helpers,
but to scan for patterns in fragments you need state for each fragmented
packet for each connection.

Regards
Patrick
