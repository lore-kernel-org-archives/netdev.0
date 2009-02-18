From: Patrick McHardy <kaber@trash.net>
Subject: Re: PF_PACKET or nfnetlink logging of skb->priority
Date: Thu, 19 Feb 2009 00:57:56 +0100
Message-ID: <499CA084.30209@trash.net>
References: <1234990308.18165.68.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1234990308.18165.68.camel@ragnarok>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Jackson wrote:
> It seems that there is nothing that can capture the skb->priority
> outside the kernel. 
>
> There is an iptables *target* "CLASSIFY", which can *set* skb->priority,
> but there is no iptables *match* based on it.
>
> tcpdump/pcap/PF_PACKET are oblivious to skb->priority.
>
> netfilter netlink queue can export the skb->mark like the right
> mechanism, but it doesn't touch skb->priority anywhere.   Perhaps there
> needs to be a another one in include/linux/netfilter/nfnetlink_queue.h:
>
> enum nfqnl_attr_type {
>         NFQA_UNSPEC,
>         NFQA_PACKET_HDR,
>         NFQA_VERDICT_HDR,               /* nfqnl_msg_verdict_hrd */
>         NFQA_MARK,   
> ... etc
> 	NFQA_SKBPRIORITY
>
> The specific use I'm thinking of now, is troubleshooting priority
> queueing with "tc" by being able to log or tcpdump traffic for a
> specific qdisc/class.
>
> It might also be nice to be able to tcpdump and/or log packets going
> into or out of a specific qdisc/class, but I'd settle for dumping
> packets based on skb->priority.
>   

I think this makes a lot of sense for nfnetlink_queue/log, I'll
gladly take patches :) It should also support changing the priority
using nfnetlink_queue, that would simplify userspace classification
since you don't need to map to mark values, just to have the
classifier map it back to classes.

For libpcap the main problem will probably be that its meta data
that needs to be stored in the pseudo header and you'll need to
keep the format compatible and the tools need to be changed to
interpret it. Using netfilter definitely looks like the easier
route :)


