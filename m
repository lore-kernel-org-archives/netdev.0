From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Mon, 25 Apr 2005 17:28:57 +0200
Message-ID: <426D0CB9.4060500@trash.net>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> You'll still BUG if the destination is multicast/broadcast.  I'm also
> unsure whether ipt_REJECT isn't susceptible to the same problem.
> Luckily ipt_MIRROR is no more :)

ipt_REJECT is fine, ip_route_input() is only used in NF_IP_FORWARD.
But you're right about multicast/broadcast still causing problems,
I'll have another look.

> What are the issues with getting rid of the ip_route_input path
> altogether?
> 
> The only thing we gain over calling ip_route_output is the ability
> to set the input device.  But even that is just a fake derived from
> the source address in a deterministic way.  Therefore any effects
> achievable through using ip_route_input can also be done by simply
> reconfiguring the policy routing table to look at the local source
> addresses instead of (or in conjunction with) the input device.

No, ip_route_me_harder() can be called for packets with non-local
source. ip_route_output_slow() rejects non-local source addresses,
so the only way to use them for policy routing is by using
ip_route_input().

Regards
Patrick
