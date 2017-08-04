From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] MIPS: Add missing file for eBPF JIT.
Date: Fri, 04 Aug 2017 15:05:19 +0200
Message-ID: <5984710F.4010301@iogearbox.net>
References: <20170804001012.24901-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, James.Cowgill@imgtec.com,
        markos.chandras@imgtec.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804001012.24901-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2017 02:10 AM, David Daney wrote:
> Inexplicably, commit f381bf6d82f0 ("MIPS: Add support for eBPF JIT.")
> lost a file somewhere on its path to Linus' tree.  Add back the
> missing ebpf_jit.c so that we can build with CONFIG_BPF_JIT selected.
>
> This version of ebpf_jit.c is identical to the original except for two
> minor change need to resolve conflicts with changes merged from the
> BPF branch:
>
> A) Set prog->jited_len = image_size;
> B) Use BPF_TAIL_CALL instead of BPF_CALL | BPF_X
>
> Fixes: f381bf6d82f0 ("MIPS: Add support for eBPF JIT.")
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>
> It might be best to merge this along the path of BPF fixes rather than
> MIPS, as the MIPS maintainer (Ralf) seems to be inactive recently.

Looks like situation is that multiple people including myself tried
to contact Ralf due to 'half/mis-applied' MIPS BPF JIT in [1,2] that
sits currently in Linus tree, but never got a reply back since mid June.

Given the work was accepted long ago but incorrectly merged, would be
great if this could still be fixed up with this patch. Given Ralf seems
unfortunately unresponsive, is there a chance, if people are fine with
it, that we could try route this fix e.g. via -net instead before a
final v4.13?

Anyway, the generic pieces interacting with core BPF look good to me:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks,
Daniel

   [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=f381bf6d82f032b7410185b35d000ea370ac706b
   [2] https://patchwork.linux-mips.org/patch/16369/
