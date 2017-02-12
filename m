From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Sun, 12 Feb 2017 14:47:39 +0900
Message-ID: <20170212054739.GA13855@mtj.duckdns.org>
References: <1486787304-2805663-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>,
        Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35199 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbdBLFro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 00:47:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so6534636pge.2
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 21:47:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486787304-2805663-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 08:28:24PM -0800, Alexei Starovoitov wrote:
> If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
> to the given cgroup the descendent cgroup will be able to override
> effective bpf program that was inherited from this cgroup.
> By default it's not passed, therefore override is disallowed.
> 
> Examples:
> 1.
> prog X attached to /A with default
> prog Y fails to attach to /A/B and /A/B/C
> Everything under /A runs prog X
> 
> 2.
> prog X attached to /A with allow_override.
> prog Y fails to attach to /A/B with default (non-override)
> prog M attached to /A/B with allow_override.
> Everything under /A/B runs prog M only.
> 
> 3.
> prog X attached to /A with allow_override.
> prog Y fails to attach to /A with default.
> The user has to detach first to switch the mode.
> 
> In the future this behavior may be extended with a chain of
> non-overridable programs.
> 
> Also fix the bug where detach from cgroup where nothing is attached
> was not throwing error. Return ENOENT in such case.
> 
> Add several testcases and adjust libbpf.
> 
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

The cgroup part looks good to me.  Please feel free to add

Acked-by: Tejun Heo <tj@kernel.org>

One question tho.  Is there a specific reason to disallow attaching
!overridable program under an overridable one?  Isn't disallowing
attaching programs if the closest ancestor is !overridable enough?

Thanks.

-- 
tejun
