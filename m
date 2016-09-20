From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Tue, 20 Sep 2016 16:25:47 +0200
Message-ID: <4581ed78-24a0-de0e-b2d1-dbbfae975524@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
 <20160916195728.GA14736@ircssh.c.rugged-nimbus-611.internal>
 <1918ef04-f22f-dce3-4bb4-1275936111d0@zonque.org>
 <20160919215311.GA9723@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160919215311.GA9723-I4sfFR6g6EicJoAdRrHjTrzMkBWIpU9tytq7g7fCXyjEk0E+pv7Png@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/19/2016 11:53 PM, Sargun Dhillon wrote:
> On Mon, Sep 19, 2016 at 06:34:28PM +0200, Daniel Mack wrote:
>> On 09/16/2016 09:57 PM, Sargun Dhillon wrote:

>>> Now, with this patch, we don't have that, but I think we can reasonably add some 
>>> flag like "no override" when applying policies, or alternatively something like 
>>> "no new privileges", to prevent children from applying policies that override 
>>> top-level policy.
>>
>> Yes, but the API is already guarded by CAP_NET_ADMIN. Take that
>> capability away from your children, and they can't tamper with the
>> policy. Does that work for you?
>
> No. This can be addressed in a follow-on patch, but the use-case is that I have 
> a container orchestrator (Docker, or Mesos), and systemd. The sysadmin controls 
> systemd, and Docker is controlled by devs. Typically, the system owner wants 
> some system level statistics, and filtering, and then we want to do 
> per-container filtering.
> 
> We really want to be able to do nesting with userspace tools that are oblivious, 
> and we want to delegate a level of the cgroup hierarchy to the tool that created 
> it. I do not see Docker integrating with systemd any time soon, and that's 
> really the only other alternative.

Then we'd need to find out whether you want to block other users from
installing (thus overriding) an existing eBPF program, or if you want to
allow that but execute them all. Both is possible.

[...]

>>> It would be nice to be able to see whether or not a filter is attached to a 
>>> cgroup, but given this is going through syscalls, at least introspection
>>> is possible as opposed to something like netlink.
>>
>> Sure, there are many ways. I implemented the bpf cgroup logic using an
>> own cgroup controller once, which made it possible to read out the
>> status. But as we agreed on attaching programs through the bpf(2) system
>> call, I moved back to the implementation that directly stores the
>> pointers in the cgroup.
>>
>> First enabling the controller through the fs-backed cgroup interface,
>> then come back through the bpf(2) syscall and then go back to the fs
>> interface to read out status values is a bit weird.
>>
> Hrm, that makes sense. with the BPF syscall, would there be a way to get
> file descriptor of the currently attached BPF program?

A file descriptor is local to a task, so we would need to install a new
fd and return its number. But I'm not sure what we'd gain from that.


Thanks,
Daniel
