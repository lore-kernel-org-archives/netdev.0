From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH, RFC] Add bridged IPv6 packet filtering
Date: Tue, 31 Aug 2004 20:28:42 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <200408312028.42742.bdschuym@pandora.be>
References: <200408281713.29192.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>,
	netfilter-devel <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S.Miller" <davem@redhat.com>
In-Reply-To: <200408281713.29192.bdschuym@pandora.be>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Saturday 28 August 2004 17:13, Bart De Schuymer wrote:
Hi,

How should I proceed to get any response in this matter? Should I be 
contacting someone else? I'm no authority on IPv6, so I would like an 
informed opinion...
Mapping the IPv6 hooks onto the bridge hooks was really easy, because there is 
no NAT stuff to mess things up. This is not a complicated patch. Also, if the 
bridge-nf code causes a malfunction in ip6tables, this can be undone by 
simply setting /proc/sys/net/bridge/bridge-nf-call-ip6tables 0 untill a 
solution is available.

cheers,
Bart

> Hello,
>
> The patch below adds bridged IPv6 packet filtering.
>
> One thing I was unclear of what to do: before giving an IPv6 packet to
> ip6tables the IPv6 sanity checks are done (copied from ipv6_rcv()).
> These checks include this code snippet:
>
> if (hdr->nexthdr == NEXTHDR_HOP) {
> 	skb->h.raw = (u8*)(hdr+1);
> 	if (ipv6_parse_hopopts(skb, offsetof(struct ipv6hdr, nexthdr)) < 0) {
> 		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
> 		return 0;
> 	}
> 	hdr = skb->nh.ipv6h;
> }
>
> If it's necessary to call ipv6_parse_hopopts() then this function will need
> to be exported. Note that we only need ip6tables to behave correctly. So,
> is this function call needed to let ip6tables behave properly?
> Also, what happens if skb->h.raw = (u8*)(hdr+1); is executed once
> inside the bridge-nf code and later all the IPv6 checks are done again
> in ipv6_rcv() ? This can happen if the IPv6 packet is destined for the
> bridge box or if it's used as a router too.
>
> In short, I'd like to know which IPv6 sanity checks are absolutely
> necessary for ip6tables and if there are any implications if those checks
> are done twice.
>
> This patch has been tested by Scott MacKay <scottmackay@yahoo.com>.
>
> cheers,
> Bart
>
> --- linux-2.6.8.1/include/linux/netfilter_ipv6.h.old	Sun Aug 22 18:49:47
<snip>
