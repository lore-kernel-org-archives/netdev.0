From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v0 3/4] cgroup: net_cls: Pass in task to sock_update_classid()
Date: Wed, 17 Oct 2012 17:54:40 +0200
Message-ID: <507ED4C0.7070408@monom.org>
References: <1350479078-29361-1-git-send-email-wagi@monom.org>  <1350479078-29361-4-git-send-email-wagi@monom.org> <1350481041.26103.454.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350481041.26103.454.camel@edumazet-glaptop>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17.10.2012 15:37, Eric Dumazet wrote:
> On Wed, 2012-10-17 at 15:04 +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>>
>> sock_update_classid() assumes that the update operation always are
>> applied on the current task. sock_update_classid() needs to know on
>> which tasks to work on in order to be able to migrate task between
>> cgroups using the struct cgroup_subsys attach() callback.
>>
> ...
>
>>
>> -extern void sock_update_classid(struct sock *sk);
>> +extern void sock_update_classid(struct sock *sk, struct task_struct *task);
>>
>>   #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
>>   static inline u32 task_cls_classid(struct task_struct *p)
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 8a146cf..68c2f3b 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1214,12 +1214,12 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
>>
>>   #ifdef CONFIG_CGROUPS
>>   #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
>> -void sock_update_classid(struct sock *sk)
>> +void sock_update_classid(struct sock *sk, struct task_struct *task)
>>   {
>>   	u32 classid;
>>
>>   	rcu_read_lock();  /* doing current task, which cannot vanish. */
>> -	classid = task_cls_classid(current);
>> +	classid = task_cls_classid(task);
>>   	rcu_read_unlock();
>
>
> Comment is now misleading (since task might not be current) and
> rcu_read_lock()/rcu_read_unlock() protects nothing here, but avoid a
> lockdep splat...
>
> Hey task_cls_classid() has its own rcu protection since commit
> 3fb5a991916091a908d (cls_cgroup: Fix rcu lockdep warning)
>
> So we can safely revert Paul commit (1144182a8757f2a1)
> (We no longer need rcu_read_lock/unlock here)

Good point. Will update the series accordingly.

> (BTW net-next is not opened yet, its content outdated, although I like
> your patch series !)

I still have not figured all details on the patch submission procedure. 
Sorry about that. The time to send patches for net-next will be annonced 
by David, is this correct?
