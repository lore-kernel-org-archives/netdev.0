From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 2/3] don't take cgroup_mutex in destroy()
Date: Fri, 20 Apr 2012 12:04:11 -0300
Message-ID: <4F917AEB.7080404@parallels.com>
References: <1334875758-20939-1-git-send-email-glommer@parallels.com> <1334875758-20939-3-git-send-email-glommer@parallels.com> <20120419225704.GE10553@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120419225704.GE10553-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/19/2012 07:57 PM, Tejun Heo wrote:
> On Thu, Apr 19, 2012 at 07:49:17PM -0300, Glauber Costa wrote:
>> Most of the destroy functions are only doing very simple things
>> like freeing memory.
>>
>> The ones who goes through lists and such, already use its own
>> locking for those.
>>
>> * The cgroup itself won't go away until we free it, (after destroy)
>> * The parent won't go away because we hold a reference count
>> * There are no more tasks in the cgroup, and the cgroup is declared
>>    dead (cgroup_is_removed() == true)
>>
>> For the blk-cgroup and the cpusets, I got the impression that the mutex
>> is still necessary.
>>
>> For those, I grabbed it from within the destroy function itself.
>>
>> If the maintainer for those subsystems consider it safe to remove
>> it, we can discuss it separately.
>
> I really don't like cgroup_lock() usage spreading more.  It's
> something which should be contained in cgroup.c proper.  I looked at
> the existing users a while ago and they seemed to be compensating
> deficencies in API, so, if at all possible, let's not spread the
> disease.

Well, I can dig deeper and see if they are really needed. I don't know 
cpusets and blkcg *that* well, that's why I took them there, hoping that 
someone could enlighten me, maybe they aren't really needed even now.

I agree with the compensating: As I mentioned, most of them are already 
taking other kinds of lock to protect their structures, which is the 
right thing to do.

There were only two or three spots in cpusets and blkcg where I wasn't 
that sure that we could drop the lock... What do you say about that ?
