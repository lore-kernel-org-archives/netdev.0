From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] cgroup: get rid of populate for memcg
Date: Mon, 9 Apr 2012 17:18:52 -0300
Message-ID: <4F83442C.8040006@parallels.com>
References: <1333728250-14248-1-git-send-email-glommer@parallels.com> <1333728250-14248-3-git-send-email-glommer@parallels.com> <20120409174042.GA7522@google.com> <4F83218E.7060502@parallels.com> <20120409181331.GD7522@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120409181331.GD7522-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/09/2012 03:13 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, Apr 09, 2012 at 02:51:10PM -0300, Glauber Costa wrote:
>> On 04/09/2012 02:40 PM, Tejun Heo wrote:
>>> which BTW seems incorrect even on its
>>> own - unmounting and mounting again would probably make the same
>>> notifier registered multiple times corrupting notification chain, and
>>> ref inc on the parent.
>>
>>
>> For the maintainers: Should I fix those in a new submission, or do
>> you intend to do it yourselves?
>>
>> the refcnt dropping should probably be done in my patch, it is a new
>> leak (sorry). The hotplug notifier, as tejun pointed, was already
>> there.
>>
>> It seems simple enough to fix, so if you guys want, I can bundle it in
>> a new submission.
>
> I think it would be best to create a separate patch which is routed
> through the usual memcg path (I suppose memcg patches go through
> -mm?).
>
> Thanks.
>
Tejun,

After debugging this a bit, I found most of it not to be a problem. 
Unless I am *very* wrong (and I both read and tested stuff), mount 
operations do not recreate the root cgroup. So stuff like the hotcpu 
notifier, etc, won't be a problem.

Now, you are definitely correct in pointing out that we start leaking 
stuff now - my bad.

But I guess I can then bundle it in a new submission, after shuffling 
around stuff a bit. It is really not a bug now, so no reason to route it 
separately.
