From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Date: Mon, 26 Sep 2011 19:49:43 -0300
Message-ID: <4E810187.3000106@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-7-git-send-email-glommer@parallels.com> <CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com> <4E7DDB82.3030802@parallels.com> <20110926200247.c80f7e47.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Thelen <gthelen@google.com>, <linux-kernel@vger.kernel.org>,
	<paul@paulmenage.org>, <lizf@cn.fujitsu.com>, <ebiederm@xmission.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<kirill@shutemov.name>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110926200247.c80f7e47.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/26/2011 08:02 AM, KAMEZAWA Hiroyuki wrote:
> On Sat, 24 Sep 2011 10:30:42 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> On 09/22/2011 03:01 AM, Greg Thelen wrote:
>>> On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa<glommer@parallels.com>   wrote:
>>>> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
>>>> +{
>>>> +       return (mem == root_mem_cgroup);
>>>> +}
>>>> +
>>>
>>> Why are you adding a copy of mem_cgroup_is_root().  I see one already
>>> in v3.0.  Was it deleted in a previous patch?
>>
>> Already answered by another good samaritan.
>>
>>>> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
>>>> +{
>>>> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
>>>> +       struct mem_cgroup *parent = parent_mem_cgroup(sg);
>>>> +       struct net *net = current->nsproxy->net_ns;
>>>> +       int i;
>>>> +
>>>> +       if (!cgroup_lock_live_group(cgrp))
>>>> +               return -ENODEV;
>>>
>>> Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
>>> to sg->tcp_prot_mem[*]?
>>>
>>>> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
>>>> +{
>>>> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
>>>> +       u64 ret;
>>>> +
>>>> +       if (!cgroup_lock_live_group(cgrp))
>>>> +               return -ENODEV;
>>>
>>> Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
>>> to sg->tcp_max_memory?
>>
>> No, that is not my understanding. My understanding is this lock is
>> needed to protect against the cgroup just disappearing under our nose.
>>
>
> Hm. reference count of dentry for cgroup isn't enough ?
>
> Thanks,
> -Kame
>
think think think think think think...
Yeah, I guess it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
