From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Mon, 23 Aug 2004 17:45:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412A8FA0.1010707@us.ibm.com>
References: <OF4320C747.75C5E93A-ON88256EF9.00744FBA-88256EF9.00750996@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@redhat.com>,
        laforge@netfilter.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF4320C747.75C5E93A-ON88256EF9.00744FBA-88256EF9.00750996@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:

> So, one solution would be to set skb->dst for the head (if NULL)  based
> on a non-null fragment skb->dst. I believe that would prevent the problem
> case without dropping the fragment, since it'll be processed post-routing
> only if one of the frags is.

This would be more performant than dropping the frags, and
requiring a retransmit (or lack thereof, depending on protocol).

> When I was looking at it, I wondered if conntrack really has a need to
> reassemble itself, though. Couldn't it let IP do the reassembling and

I asked Harald this when I met him last, and he said it
does need to. So I don't think this (having conntrack
reassemble) is avoidable, unfortunately.

Of course, fragmentation, on the other hand, :), ...

thanks,
Nivedita
