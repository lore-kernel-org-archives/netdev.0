From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Oct 16 (net/sched/em_ipset.c)
Date: Wed, 16 Oct 2013 17:21:17 -0700
Message-ID: <525F2D7D.7010708@infradead.org>
References: <1381949500-501-1-git-send-email-treding@nvidia.com> <525F09B0.4080802@infradead.org> <20131016153949.5f2257b4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vitaly Lavrov <lve@guap.ru>,
	Thierry Reding <thierry.reding@gmail.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131016153949.5f2257b4@nehalam.linuxnetplumber.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/13 15:39, Stephen Hemminger wrote:
> On Wed, 16 Oct 2013 14:48:32 -0700
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 10/16/13 11:51, Thierry Reding wrote:
>>> Hi all,
>>>
>>> I've uploaded today's linux-next tree to the master branch of the
>>> repository below:
>>>
>>>         git://gitorious.org/thierryreding/linux-next.git
>>>
>>> A next-20131016 tag is also provided for convenience.
>>>
>>> Gained two new conflicts, but nothing too exciting. x86 and ARM default
>>> configurations as well as the x86 allmodconfig mostly build fine on the
>>> final tree. There was a failure for the ARM at91x40_defconfig, but the
>>> proper fix wasn't immediately obvious to me, so I've left it broken for
>>> now.
>>
>> on i386, when CONFIG_NET_NS is not enabled:
>>
>> net/sched/em_ipset.c: In function 'em_ipset_change':
>> net/sched/em_ipset.c:27:36: error: 'struct net_device' has no member named 'nd_net'
>> net/sched/em_ipset.c: In function 'em_ipset_destroy':
>> net/sched/em_ipset.c:49:34: error: 'struct net_device' has no member named 'nd_net'
>>
>>
> 
> I think this should fix.
> 

That works.  Thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org>


> 
> 
> --- a/net/sched/em_ipset.c	2013-10-06 14:48:25.030449222 -0700
> +++ b/net/sched/em_ipset.c	2013-10-16 15:38:05.030278287 -0700
> @@ -24,7 +24,7 @@ static int em_ipset_change(struct tcf_pr
>  {
>  	struct xt_set_info *set = data;
>  	ip_set_id_t index;
> -	struct net *net = qdisc_dev(tp->q)->nd_net;
> +	struct net *net = dev_net(qdisc_dev(tp->q));
>  
>  	if (data_len != sizeof(*set))
>  		return -EINVAL;
> @@ -46,7 +46,7 @@ static void em_ipset_destroy(struct tcf_
>  {
>  	const struct xt_set_info *set = (const void *) em->data;
>  	if (set) {
> -		ip_set_nfnl_put(qdisc_dev(p->q)->nd_net, set->index);
> +		ip_set_nfnl_put(dev_net(qdisc_dev(p->q)), set->index);
>  		kfree((void *) em->data);
>  	}
>  }
> --


-- 
~Randy
