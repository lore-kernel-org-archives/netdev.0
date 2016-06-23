From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/4] cgroup: bpf: Add an example to do cgroup
 checking in BPF
Date: Thu, 23 Jun 2016 11:58:18 +0200
Message-ID: <576BB2BA.2070401@iogearbox.net>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com> <1466630252-3822277-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	kernel-team-b10kYP2dOMg@public.gmane.org
To: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466630252-3822277-5-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/22/2016 11:17 PM, Martin KaFai Lau wrote:
> test_cgrp2_array_pin.c:
> A userland program that creates a bpf_map (BPF_MAP_TYPE_GROUP_ARRAY),
> pouplates/updates it with a cgroup2's backed fd and pins it to a
> bpf-fs's file.  The pinned file can be loaded by tc and then used
> by the bpf prog later.  This program can also update an existing pinned
> array and it could be useful for debugging/testing purpose.
>
> test_cgrp2_tc_kern.c:
> A bpf prog which should be loaded by tc.  It is to demonstrate
> the usage of bpf_skb_in_cgroup.
>
> test_cgrp2_tc.sh:
> A script that glues the test_cgrp2_array_pin.c and
> test_cgrp2_tc_kern.c together.  The idea is like:
> 1. Use test_cgrp2_array_pin.c to populate a BPF_MAP_TYPE_CGROUP_ARRAY
>     with a cgroup fd
> 2. Load the test_cgrp2_tc_kern.o by tc
> 3. Do a 'ping -6 ff02::1%ve' to ensure the packet has been
>     dropped because of a match on the cgroup
>
> Most of the lines in test_cgrp2_tc.sh is the boilerplate
> to setup the cgroup/bpf-fs/net-devices/netns...etc.  It is
> not bulletproof on errors but should work well enough and
> give enough debug info if things did not go well.
>
> Signed-off-by: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
> Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Btw, when no bpf fs is mounted, tc will already auto-mount it. I noticed in
your script, you do mount the fs manually. I guess it's okay to leave it like
this, but I hope users won't wrongly copy it assuming they /have/ to mount it
themselves.
