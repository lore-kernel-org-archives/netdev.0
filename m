From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 06:25:37 +0100
Message-ID: <41C26DD1.7070006@trash.net>
References: <Xine.LNX.4.44.0412170012040.12382-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0412170012040.12382-100000@thoron.boston.redhat.com>
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

James Morris wrote:

>This at least needs CAP_NET_ADMIN.
>
It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
replace iptables rules :)

Regards
Patrick

>
>On Thu, 16 Dec 2004, Bryan Fulton wrote:
>  
>
>>////////////////////////////////////////////////////////
>>// 3:   /net/ipv6/netfilter/ip6_tables.c::do_replace  //
>>////////////////////////////////////////////////////////
>> 
>>- tainted unsigned scalar tmp.num_counters multiplied and passed to
>>vmalloc (1161) and memset (1166) which could overflow or be too large
>>
>>Call to function "copy_from_user" TAINTS argument "tmp"
>>
>>1143            if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
>>1144                    return -EFAULT;
>>
>>...
>>
>>TAINTED variable "((tmp).num_counters * 16)" was passed to a tainted
>>sink.
>>
>>1161            counters = vmalloc(tmp.num_counters * sizeof(struct
>>ip6t_counters));
>>1162            if (!counters) {
>>1163                    ret = -ENOMEM;
>>1164                    goto free_newinfo;
>>1165            }
>>
>>TAINTED variable "((tmp).num_counters * 16)" was passed to a tainted
>>sink.
>>
>>1166            memset(counters, 0, tmp.num_counters * sizeof(struct
>>ip6t_counters));
>>
>>    
>>
>
>  
>
