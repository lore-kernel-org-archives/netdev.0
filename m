From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Wed, 16 May 2012 11:03:47 +0400
Message-ID: <4FB35153.3080309@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB0621C.3010604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB0621C.3010604-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/14/2012 05:38 AM, Li Zefan wrote:
>> +static void disarm_static_keys(struct mem_cgroup *memcg)
> 
>> +{
>> +#ifdef CONFIG_INET
>> +	if (memcg->tcp_mem.cg_proto.activated)
>> +		static_key_slow_dec(&memcg_socket_limit_enabled);
>> +#endif
>> +}
> 
> 
> Move this inside the ifdef/endif below ?
> 
> Otherwise I think you'll get compile error if !CONFIG_INET...

I don't fully get it.

We are supposed to provide a version of it for
CONFIG_CGROUP_MEM_RES_CTLR_KMEM and an empty version for
!CONFIG_CGROUP_MEM_RES_CTLR_KMEM

Inside the first, we take an action for CONFIG_INET, and no action for
!CONFIG_INET.

Bear in mind that the slab patches will add another test to that place,
and that's why I am doing it this way from the beginning.

Well, that said, I not only can be wrong, I very frequently am.

But I just compiled this one with and without CONFIG_INET, and it seems
to be going alright.


>> +
>>   #ifdef CONFIG_INET
>>   struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>>   {
>> @@ -452,6 +462,11 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>>   }
>>   EXPORT_SYMBOL(tcp_proto_cgroup);
>>   #endif /* CONFIG_INET */
>> +#else
>> +static inline void disarm_static_keys(struct mem_cgroup *memcg)
>> +{
>> +}
>> +
>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
