From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Sun, 12 Feb 2017 21:52:41 -0500 (EST)
Message-ID: <20170212.215241.895807377087801300.davem@davemloft.net>
References: <1486787304-2805663-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, dsa@cumulusnetworks.com, daniel@zonque.org,
        tj@kernel.org, luto@amacapital.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdBMCwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 21:52:43 -0500
In-Reply-To: <1486787304-2805663-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 10 Feb 2017 20:28:24 -0800

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

Applied.
