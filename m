From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 2/6] cgroup: add support for eBPF programs
Date: Thu, 24 Nov 2016 09:21:58 +0100
Message-ID: <0f73e359-e3d9-4344-ecae-7a03945aaf8b@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
 <1479916350-28462-3-git-send-email-daniel@zonque.org>
 <CAKoUArnq-DpwMJPdUutyR7fAhEN_6Spkw3NXkK5O=jZOQR8BXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKoUArnq-DpwMJPdUutyR7fAhEN_6Spkw3NXkK5O=jZOQR8BXA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rami,

On 11/23/2016 11:46 PM, Rami Rosen wrote:
> A minor comment:
> 
>> +/**
>> + * __cgroup_bpf_update() - Update the pinned program of a cgroup, and
>> + *                         propagate the change to descendants
>> + * @cgrp: The cgroup which descendants to traverse
>> + * @parent: The parent of @cgrp, or %NULL if @cgrp is the root
>> + * @prog: A new program to pin
>> + * @type: Type of pinning operation (ingress/egress)
>> + *
>> + * Each cgroup has a set of two pointers for bpf programs; one for eBPF
>> + * programs it owns, and which is effective for execution.
>> + *
> You have in the following section twice identical checks, for If @prog
> is %NULL".
> Shouldn't it be here (in the first case only) "If @prog is not %NULL"
> instead "If @prog is %NULL"?

Yes, you're right, thanks for spotting.

If possible, I would like to not send a v10 just for this one missing
word in the comments though, but rather fix that up in a separate patch
afterwards.


Thanks,
Daniel


> 
>> + * If @prog is %NULL, this function attaches a new program to the cgroup and
>> + * releases the one that is currently attached, if any. @prog is then made
>> + * the effective program of type @type in that cgroup.
>> + *
>> + * If @prog is %NULL, the currently attached program of type @type is released,
>> + * and the effective program of the parent cgroup (if any) is inherited to
>> + * @cgrp.
>> + *
> 
> 
> Regard,
> Rami Rosen
> 
