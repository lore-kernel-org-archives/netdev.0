From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Thu, 17 May 2012 19:27:09 +0900
Message-ID: <4FB4D27D.7020009@jp.fujitsu.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <20120516140637.17741df6.akpm@linux-foundation.org> <4FB46B4C.3000307@parallels.com> <20120516223715.5d1b4385.akpm@linux-foundation.org> <4FB4CA4D.50608@parallels.com> <4FB4D061.10406@jp.fujitsu.com> <4FB4D14D.4020303@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB4D14D.4020303-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2012/05/17 19:22), Glauber Costa wrote:

> On 05/17/2012 02:18 PM, KAMEZAWA Hiroyuki wrote:
>> (2012/05/17 18:52), Glauber Costa wrote:
>>
>>> On 05/17/2012 09:37 AM, Andrew Morton wrote:
>>>>>>   If that happens, locking in static_key_slow_inc will prevent any damage.
>>>>>>   My previous version had explicit code to prevent that, but we were
>>>>>>   pointed out that this is already part of the static_key expectations, so
>>>>>>   that was dropped.
>>>> This makes no sense.  If two threads run that code concurrently,
>>>> key->enabled gets incremented twice.  Nobody anywhere has a record that
>>>> this happened so it cannot be undone.  key->enabled is now in an
>>>> unknown state.
>>>
>>> Kame, Tejun,
>>>
>>> Andrew is right. It seems we will need that mutex after all. Just this
>>> is not a race, and neither something that should belong in the
>>> static_branch interface.
>>>
>>
>>
>> Hmm....how about having
>>
>> res_counter_xchg_limit(res,&old_limit, new_limit);
>>
>> if (!cg_proto->updated&&  old_limit == RESOURCE_MAX)
>> 	....update labels...
>>
>> Then, no mutex overhead maybe and activated will be updated only once.
>> Ah, but please fix in a way you like. Above is an example.
> 
> I think a mutex is a lot cleaner than adding a new function to the 
> res_counter interface.
> 
> We could do a counter, and then later decrement the key until the 
> counter reaches zero, but between those two, I still think a mutex here 
> is preferable.
> 
> Only that, instead of coming up with a mutex of ours, we could export 
> and reuse set_limit_mutex from memcontrol.c
> 


ok, please.

thx,
-Kame

> 
>> Thanks,
>> -Kame
>> (*) I'm sorry I won't be able to read e-mails, tomorrow.
>>
> Ok Kame. I am not in a terrible hurry to fix this, it doesn't seem to be 
> hurting any real workload.
> 
> 
