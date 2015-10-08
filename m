From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Thu, 8 Oct 2015 10:42:15 -0700
Message-ID: <CAGXu5jJUnNuvBHP9_AKmsPUH1oKEgT3T9g0G0kx7z+EPUc=BPw@mail.gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
	<1444078101-29060-2-git-send-email-ast@plumgrid.com>
	<5612F639.2050305@iogearbox.net>
	<56131B1F.80002@plumgrid.com>
	<5613C261.4080302@iogearbox.net>
	<56158CAF.9030209@plumgrid.com>
	<561597A6.4000203@iogearbox.net>
	<CAGXu5jLM5Wp_PjdcEcxUo-VoEmsSycF236MZaJd2wvLjbQx+eQ@mail.gmail.com>
	<5615AF92.50402@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38072 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933212AbbJHRmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:42:16 -0400
Received: by igxx6 with SMTP id x6so18133453igx.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:42:16 -0700 (PDT)
In-Reply-To: <5615AF92.50402@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 4:49 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 10/7/15 3:22 PM, Kees Cook wrote:
>>>
>>> Yes, I agree with you that there would be a CVE regardless. I still
>>> >like the option of configurable access, not a big fan of the sysctl
>>> >either. Thinking out loudly, what about a Kconfig option? We started
>>> >out like this on bpf(2) itself (initially under expert settings, now
>>> >afaik not anymore), and depending on usage scenarios, a requirement
>>> >could be to have immutable cap_sys_admin-only, for other use-cases a
>>> >requirement on the kernel might instead be to have unprivileged users
>>> >as well.
>>
>> It'd be nice to have it just be a Kconfig, but this shoots
>> distro-users in the foot if a distro decides to include unpriv bpf and
>> the user doesn't want it. I think it's probably a good idea to keep
>> the sysctl.
>
>
> I don't like introducing Kconfig for no clear reason. It only adds
> to the testing matrix and makes it harder to hack around.
> Paranoid distros can disable bpf via single config already,
> there is no reason to go more fine grained here.
> Unpriv checks add minimal amount of code, so even for tinification
> purpose there is no need to chop of few bytes. tiny kernels would
> disable bpf all together.
>
> As far as sysctl we can look at two with similar purpose:
> sysctl_perf_event_paranoid and modules_disabled.
> First one is indeed multi level, but not because of the fear of bugs,
> but because of real security implications. Like raw events on
> hyperthreaded cpu or uncore events can extract data from other
> user processes. So it controls these extra privileges.
> For bpf there are no hw implications to deal with.
> If we make seccomp+bpf in the future it shouldn't need another knob
> or extra bit. There are no extra privileges to grant, so not needed.
>
> modules_disabled is off by default and can be toggled on once.
> I think for paranoid distro users that "don't want bpf" that is
> the better model.
> So I'm thinking to do sysctl_unprivileged_bpf_disabled that will be
> 0=off by default (meaning that users can load unpriv socket filter
> programs and seccomp in the future) and that can be switched
> to 1=on once and stay that way until reboot.
> I think that's the best balance that avoids adding checks to all
> apps that want to use bpf and admins can still act on it.
> From app point of view it's no different than bpf syscall
> was not compiled in. So single feature test for bpf syscall will
> be enough.

I think this would be great. :)

-Kees

-- 
Kees Cook
Chrome OS Security
