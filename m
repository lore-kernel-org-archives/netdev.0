From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] bpf: unprivileged
Date: Mon, 12 Oct 2015 19:22:32 -0700 (PDT)
Message-ID: <20151012.192232.764687069258026388.davem@davemloft.net>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1444281803-24274-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Wed,  7 Oct 2015 22:23:20 -0700

> v1-v2:
> - this set logically depends on cb patch
>   "bpf: fix cb access in socket filter programs":
>   http://patchwork.ozlabs.org/patch/527391/
>   which is must have to allow unprivileged programs.
>   Thanks Daniel for finding that issue.
> - refactored sysctl to be similar to 'modules_disabled'
> - dropped bpf_trace_printk
> - split tests into separate patch and added more tests
>   based on discussion
> 
> v1 cover letter:
> I think it is time to liberate eBPF from CAP_SYS_ADMIN.
> As was discussed when eBPF was first introduced two years ago
> the only piece missing in eBPF verifier is 'pointer leak detection'
> to make it available to non-root users.
> Patch 1 adds this pointer analysis.
> The eBPF programs, obviously, need to see and operate on kernel addresses,
> but with these extra checks they won't be able to pass these addresses
> to user space.
> Patch 2 adds accounting of kernel memory used by programs and maps.
> It changes behavoir for existing root users, but I think it needs
> to be done consistently for both root and non-root, since today
> programs and maps are only limited by number of open FDs (RLIMIT_NOFILE).
> Patch 2 accounts program's and map's kernel memory as RLIMIT_MEMLOCK.
> 
> Unprivileged eBPF is only meaningful for 'socket filter'-like programs.
> eBPF programs for tracing and TC classifiers/actions will stay root only.
> 
> In parallel the bpf fuzzing effort is ongoing and so far
> we've found only one verifier bug and that was already fixed.
> The 'constant blinding' pass also being worked on.
> It will obfuscate constant-like values that are part of eBPF ISA
> to make jit spraying attacks even harder.

Scary stuff, but I don't see any major problems, so series applied!
