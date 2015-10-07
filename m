From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Wed, 7 Oct 2015 15:22:55 -0700
Message-ID: <CAGXu5jLM5Wp_PjdcEcxUo-VoEmsSycF236MZaJd2wvLjbQx+eQ@mail.gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
	<1444078101-29060-2-git-send-email-ast@plumgrid.com>
	<5612F639.2050305@iogearbox.net>
	<56131B1F.80002@plumgrid.com>
	<5613C261.4080302@iogearbox.net>
	<56158CAF.9030209@plumgrid.com>
	<561597A6.4000203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34678 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbbJGWW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 18:22:56 -0400
Received: by igcpb10 with SMTP id pb10so2244080igc.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 15:22:55 -0700 (PDT)
In-Reply-To: <561597A6.4000203@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 3:07 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/07/2015 11:20 PM, Alexei Starovoitov wrote:
>>
>> On 10/6/15 5:45 AM, Daniel Borkmann wrote:
>>>
>>> Should instead something similar be adapted on bpf(2) as well? Or, would
>>> that even be more painful for application developers shipping their stuff
>>> through distros in the end (where they might then decide to just setup
>>> everything BPF-related and then drop privs)?
>>
>>
>> I think loading as root and then dropping privs won't work in many
>> cases, since apps still need to access maps even after dropping privs
>> and today it's not possible, since cap_sys_admin is tested for every
>> bpf syscall.
>
>
> Yep, maps-only would then need to be made accessible in some way.
>
>>> I'm also wondering with regards to seccomp, which could adapt to eBPF at
>>> some point and be used by unprivileged programs. Perhaps then, a single
>>> paranoia alike setting might not suit to all eBPF subsystem users. Any
>>> ideas?
>>
>>
>> There is no such paranoid sysctl for cBPF, so there is no reason to
>> add one for eBPF other than fear.
>> Adding multiple sysctl knobs for seccomp, socket, tracing is only
>> reflection of even higher fear.
>> What sysadmins suppose to do with such sysctl when kernel is kinda
>> saying 'may be something unsafe here you're on your own' ?
>> Also the presence of this sysctl_bpf_enable_unprivileged or any other
>> one doesn't help with CVEs. Any bug with security implications will
>> be a CVE regardless, so I think the better course of action is to
>> avoid introducing this sysctl.
>
>
> Yes, I agree with you that there would be a CVE regardless. I still
> like the option of configurable access, not a big fan of the sysctl
> either. Thinking out loudly, what about a Kconfig option? We started
> out like this on bpf(2) itself (initially under expert settings, now
> afaik not anymore), and depending on usage scenarios, a requirement
> could be to have immutable cap_sys_admin-only, for other use-cases a
> requirement on the kernel might instead be to have unprivileged users
> as well.

It'd be nice to have it just be a Kconfig, but this shoots
distro-users in the foot if a distro decides to include unpriv bpf and
the user doesn't want it. I think it's probably a good idea to keep
the sysctl.

-Kees

>
>> We've discussed adding something like CAP_BPF to control it,
>> but then again, do we want this because of fear of bugs or because
>> it's actually needed. I think the design of all CAP_* is to give
>> unprivileged users permissions to do something beyond normal that
>> can potentially be harmful for other users or the whole system.
>> In this case it's not the case. One user can load eBPF programs
>> and maps up to its MEMLOCK limit and they cannot interfere with
>> other users or affect the host, so CAP_BPF is not necessary either.
>
>
> Thanks,
> Daniel



-- 
Kees Cook
Chrome OS Security
