From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Sat, 11 Feb 2017 18:14:12 +0100
Message-ID: <589F4664.3060703@iogearbox.net>
References: <1486787304-2805663-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42323 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbdBKROV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 12:14:21 -0500
In-Reply-To: <1486787304-2805663-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2017 05:28 AM, Alexei Starovoitov wrote:
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

Seems ok from my side:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
