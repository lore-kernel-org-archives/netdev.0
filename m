From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Thu, 08 Oct 2015 00:07:34 +0200
Message-ID: <561597A6.4000203@iogearbox.net>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com> <1444078101-29060-2-git-send-email-ast@plumgrid.com> <5612F639.2050305@iogearbox.net> <56131B1F.80002@plumgrid.com> <5613C261.4080302@iogearbox.net> <56158CAF.9030209@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56158CAF.9030209-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/07/2015 11:20 PM, Alexei Starovoitov wrote:
> On 10/6/15 5:45 AM, Daniel Borkmann wrote:
>> Should instead something similar be adapted on bpf(2) as well? Or, would
>> that even be more painful for application developers shipping their stuff
>> through distros in the end (where they might then decide to just setup
>> everything BPF-related and then drop privs)?
>
> I think loading as root and then dropping privs won't work in many
> cases, since apps still need to access maps even after dropping privs
> and today it's not possible, since cap_sys_admin is tested for every
> bpf syscall.

Yep, maps-only would then need to be made accessible in some way.

>> I'm also wondering with regards to seccomp, which could adapt to eBPF at
>> some point and be used by unprivileged programs. Perhaps then, a single
>> paranoia alike setting might not suit to all eBPF subsystem users. Any
>> ideas?
>
> There is no such paranoid sysctl for cBPF, so there is no reason to
> add one for eBPF other than fear.
> Adding multiple sysctl knobs for seccomp, socket, tracing is only
> reflection of even higher fear.
> What sysadmins suppose to do with such sysctl when kernel is kinda
> saying 'may be something unsafe here you're on your own' ?
> Also the presence of this sysctl_bpf_enable_unprivileged or any other
> one doesn't help with CVEs. Any bug with security implications will
> be a CVE regardless, so I think the better course of action is to
> avoid introducing this sysctl.

Yes, I agree with you that there would be a CVE regardless. I still
like the option of configurable access, not a big fan of the sysctl
either. Thinking out loudly, what about a Kconfig option? We started
out like this on bpf(2) itself (initially under expert settings, now
afaik not anymore), and depending on usage scenarios, a requirement
could be to have immutable cap_sys_admin-only, for other use-cases a
requirement on the kernel might instead be to have unprivileged users
as well.

> We've discussed adding something like CAP_BPF to control it,
> but then again, do we want this because of fear of bugs or because
> it's actually needed. I think the design of all CAP_* is to give
> unprivileged users permissions to do something beyond normal that
> can potentially be harmful for other users or the whole system.
> In this case it's not the case. One user can load eBPF programs
> and maps up to its MEMLOCK limit and they cannot interfere with
> other users or affect the host, so CAP_BPF is not necessary either.

Thanks,
Daniel
