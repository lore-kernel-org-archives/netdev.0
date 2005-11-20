From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Sun, 20 Nov 2005 19:07:30 +0100
Message-ID: <4380BB62.8050404@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<200511201902.10179.lists@naasa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: jplatte@naasa.net
In-Reply-To: <200511201902.10179.lists@naasa.net>
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

Joerg Platte wrote:
> Am Sonntag, 20. November 2005 17:31 schrieb Patrick McHardy:
> Hi!
> 
>>- policy lookups after NAT:
>>
>>When NAT changes a packet it already calls ip_route_me_harder, which
>>reroutes the packet and does a new policy lookup. It only looks at
>>the IP addresses however, changing the port numbers require a new
>>policy lookup as well. It also doesn't reroute in POST_ROUTING, since
>>the packet has already been routed. To behave more like a regular
>>tunnel device a policy lookup is now also done after SNAT and the
>>packet is passed to dst_output again if the lookup yielded a new
>>policy.
> 
> I suppose, this is the reason, why masqueraded packages leave a recent kernel 
> unencrypted, even if they would match the policy. It's still not implemented 
> in mainline. Am I right? If yes, I hope your patches will be merged as soon 
> as possible :-)

You're right, that's the reason. Since the patches touch quite a lot of
code they won't make it in 2.6.15, though.
