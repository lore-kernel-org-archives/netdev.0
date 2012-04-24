From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 3/5] change number_of_cpusets to an atomic
Date: Tue, 24 Apr 2012 13:15:36 -0300
Message-ID: <4F96D1A8.6040604@parallels.com>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com> <1335209867-1831-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204241001050.26005@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1204241001050.26005-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/24/2012 12:02 PM, Christoph Lameter wrote:
> On Mon, 23 Apr 2012, Glauber Costa wrote:
>
>> This will allow us to call destroy() without holding the
>> cgroup_mutex(). Other important updates inside update_flags()
>> are protected by the callback_mutex.
>>
>> We could protect this variable with the callback_mutex as well,
>> as suggested by Li Zefan, but we need to make sure we are protected
>> by that mutex at all times, and some of its updates happen inside the
>> cgroup_mutex - which means we would deadlock.
>
> Would this not also be a good case to introduce static branching?
>
> number_of_cpusets is used to avoid going through unnecessary processing
> should there be no cpusets in use.
>
Well,

static branches comes with a set of problems themselves, so I usually 
prefer to use them only in places where we don't want to pay even a 
cache miss if we can avoid, or a function call, or anything like that - 
like the slub cache alloc as you may have seen in my kmem memcg series.

It doesn't seem to be the case here.
