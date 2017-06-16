From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 2/3] samples/bpf: Add define __EMITTING_BPF__ when
 building BPF
Date: Fri, 16 Jun 2017 12:14:34 -0400 (EDT)
Message-ID: <20170616.121434.859810061597099237.davem@davemloft.net>
References: <20170615223543.22867-1-david.daney@cavium.com>
        <20170615223543.22867-3-david.daney@cavium.com>
        <5943B1C6.7040809@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, catalin.marinas@arm.com, will.deacon@arm.com,
        linux-arm-kernel@lists.infradead.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5943B1C6.7040809@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 16 Jun 2017 12:24:06 +0200

> On 06/16/2017 12:35 AM, David Daney wrote:
>> ... this allows gating of inline assembly code that causes llvm to
>> fail when emitting BPF.
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
> 
> I don't have a better idea at the moment, perhaps there could be
> a clang rewrite plugin that would ignore all inline assembly code
> since this is never used from BPF progs. Hmm. Really ugly that
> we have to add this __EMITTING_BPF__ into arch asm files, but I
> don't have a better idea for an immediate workaround right now ...
> I would really prefer if we could avoid just for the sake of the
> kernel samples going down the road of adding a
> !defined(__EMITTING_BPF__)
> into a uapi asm header for mips, though. Is this coming from
> networking sample code or rather tracing?

The problem is that we include the arch include/asm files at all.

When we build bpf stuff, we should have a set of asm/ files
specifically for builds targetting BPF.

Let's just fix this right and stop putting all of these hacks in.

Thank you.
