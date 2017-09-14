From: David Miller <davem@davemloft.net>
Subject: Re: Bug with BPF_ALU64 | BPF_END?
Date: Thu, 14 Sep 2017 11:14:24 -0700 (PDT)
Message-ID: <20170914.111424.934672262035736390.davem@davemloft.net>
References: <52c7df55-84d9-f6d2-ed84-51ac90eb6bcc@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdINSOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 14:14:25 -0400
In-Reply-To: <52c7df55-84d9-f6d2-ed84-51ac90eb6bcc@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 14 Sep 2017 18:53:17 +0100

> Is BPF_END supposed to only be used with BPF_ALU, never with BPF_ALU64?
> In kernel/bpf/core.c:___bpf_prog_run(), there are only jump table targets
>  for the BPF_ALU case, not for the BPF_ALU64 case (opcodes 0xd7 and 0xdf).
> But the verifier doesn't enforce this; by crafting a program that uses
>  these opcodes I can get a WARN when they're run (without JIT; it looks
>  like the x86 JIT, at least, won't like it either).
> Proposed patch below the cut; build-tested only.

Good catch.

A really neat test would be a program that uploads random BPF programs
into the kernel, in a syzkaller'ish way.  It might have triggered this
(eventually).
