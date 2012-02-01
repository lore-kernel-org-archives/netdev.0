From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/6] cls_cgroup: remove redundant rcu_read_lock/unlock
Date: Wed, 01 Feb 2012 15:20:00 +0800
Message-ID: <4F28E7A0.6000309@cn.fujitsu.com>
References: <4F28E1D1.900@cn.fujitsu.com> <4F28E22A.703@cn.fujitsu.com> <1328080039.22641.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Herbert Xu <herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328080039.22641.2.camel@edumazet-laptop>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>

>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 213c856..c0bab23 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1160,9 +1160,7 @@ void sock_update_classid(struct sock *sk)
>>  {
>>  	u32 classid;
>>  
>> -	rcu_read_lock();  /* doing current task, which cannot vanish. */
>>  	classid = task_cls_classid(current);
>> -	rcu_read_unlock();
>>  	if (classid && classid != sk->sk_classid)
>>  		sk->sk_classid = classid;
> 
> Yes, this seems fine.
> 
> Then, I wonder why we do the "if (classid && classid != sk->sk_classid)"
> 
> before the :
> 
> 	sk->sk_classid = classid;
> 
> This seems unnecessary checks.
> 

I was wondering about this too. He who added this may provide us with an
answer.
