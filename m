From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Wed, 24 Mar 2004 03:39:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4060F4F6.5020400@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040324021514.GM3387@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexander Samad <alex@samad.com.au>
In-Reply-To: <20040324021514.GM3387@samad.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexander Samad wrote:
> Hi
> 
> Think their might be a problem with this patch.
> 
> Potientially a packet could traverse the pre, forward and the post
> routing, at which point it can be SNAT'ed or MASQ'ed and then re
> injected into route_me_harder.  This potiential could allow packets to
> be rerouted based on the new src/dst addresses differently to the intail
> packet but this new packet doesn't traverse any of the chains with the
> new information.

This is just as without the patches, SNAT in POST_ROUTING never causes
a packet to re-traverse the hooks. There is one minor difference,
packets which match a policy after NAT stop traversing the hooks at
NF_IP_PRI_NAT_SRC priority. I will fix this this for the final version.

Regards
Patrick

> 
> Alex
> 
> On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> 
>>This patch adds policy lookups to ip_route_me_harder and makes NAT
>>reroute for any change that affects route/policy lookups.
>>
> 
> 
> 
