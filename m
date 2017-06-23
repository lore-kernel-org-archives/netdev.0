From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 01/15] bpf: BPF support for sock_ops
Date: Fri, 23 Jun 2017 23:15:22 +0200
Message-ID: <594D84EA.5080203@iogearbox.net>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-2-brakmo@fb.com> <594C47A1.1080102@iogearbox.net> <B03E3B5A-50E2-4291-B091-23927AF6846F@fb.com> <594C5065.2010900@iogearbox.net> <82AC8CB1-F770-4EFA-9223-E2C94626582F@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55107 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdFWVP2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 17:15:28 -0400
In-Reply-To: <82AC8CB1-F770-4EFA-9223-E2C94626582F@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2017 01:57 AM, Lawrence Brakmo wrote:
> On 6/22/17, 4:19 PM, "netdev-owner@vger.kernel.org on behalf of Daniel Borkmann" <netdev-owner@vger.kernel.org on behalf of daniel@iogearbox.net> wrote:
>
>      On 06/23/2017 12:58 AM, Lawrence Brakmo wrote:
>      [...]
>      > Daniel, I see value for having a global program, so I would like to keep that. When
>      > this patchset is accepted, I will submit one that adds support for per cgroup
>      > sock_ops programs, with the option to use the global one if none is
>      > specified for a cgroup. We could also have the option of the cgroup sock_ops
>      > program choosing if the global program should run for a particular op based on
>      > its return value. We can iron it out the details when that patch is submitted.
>
>      Hm, could you elaborate on the value part compared to per cgroups ops?
>      My understanding is that per cgroup would already be a proper superset
>      of just the global one anyway, so why not going with that in the first
>      place since you're working on it?
>
>      What would be the additional value? How would global vs per cgroup one
>      interact with each other in terms of enforcement e.g., there's already
>      semantics in place for cgroups descendants, would it be that we set
>      TCP parameters twice or would you disable the global one altogether?
>      Just wondering as you could avoid these altogether with going via cgroups
>      initially.
>
>      Thanks,
>      Daniel
>
> Well, for starters the global program will work even if CONFIG_CGROUP_BPF is
> not defined. It is also an easier concept for when a global program is all that

Otoh, major distros are highly likely to enable this on by default anyway.

> is required. But I also had in mind that behaviors that were in common for
> most cgroup programs could be handled by the global program instead of
> adding it to all cgroup programs. In this scenario the global program
> represents the default behavior that can be override by the cgroup
> program (per op). For example, the cgroup program could return a value
> to indicate that that op should be passed to the global program.

But then you would need to go through two program passes for setting
such parameters? Other option could be to make the per cgroup ops more
fine grained and use the effective one that was inherited for delegating
to default ops. My gut feeling is just that this makes interactions to
manage this and enforcement in combination with the later planned per
cgroups ops more complex if the same use-case could indeed be resolved
with per cgroups only.

> I agree 100% with you on the value of cgroup programs, but I just happen
> to think there is also value in the global program.
>
> Thanks,
> Lawrence
