From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Fri, 19 Mar 2004 16:30:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405B1215.2070909@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net>	<20040308115858.75cdddca.davem@redhat.com>	<4059CF17.8090907@trash.net> <20040318221645.2b67e433.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040318221645.2b67e433.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 18 Mar 2004 17:32:23 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>This patch adds policy lookups to ip_route_me_harder and makes NAT
>>reroute for any change that affects route/policy lookups.
> 
> 
> Why are you deleting that "fl.proto = iph->protocol;" line in
> net/core/netfilter.c?  Is something else going to set it properly?
> 

The patch adds a call to decode_session/xfrm_lookup below. This
handles packets with local and non-local source, setting fl.proto
only handles packets with local source. Also we must check if the
packet was already transformed to prevent loops.

Regards
Patrick
