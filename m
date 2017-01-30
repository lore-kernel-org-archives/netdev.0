From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 30 Jan 2017 16:08:54 +0530
Message-ID: <20170130103853.GA34633@in3o.xyz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
	linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: Kees Cook <keescook@chromium.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Mircea Gherzan <mgherzan@gmail.com>
Return-path: <kernel-hardening-return-6194-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi all,

Please ignore last copy of this mail. Kernel mailing lists bounced my
last mail back because of HTML content.

Just starting a new thread with proper heading on the main kernel
hardening and net-dev mailing list so that other people can be involved
in this. Please don't take this as a personal mail.

I am working on conversion of arm32 cBPF into eBPF JIT. I wanted some
help, regarding understanding of kernel code, from the dev available on
the mailing list. If you look at the ./arch/arm/net/bpf_jit_32.c code,
you will see jit_ctx structure. If anybody could help me understand what
each fields of this structure represent then it would be great.

Also, currently I am mapping the eBPF registers to arm 32 bit registers
in the following way.

> static const int bpf2a32[] = {
>
>         /* return value from in-kernel function, and exit value from
>         eBPF
> */
>         [BPF_REG_0] = ARM_R0,
>
>         /* arguments from eBPF program to in-kernel function */
>
>         [BPF_REG_1] = ARM_R1,
>
>         [BPF_REG_2] = ARM_R2,
>
>         [BPF_REG_3] = ARM_R3,
>
>         [BPF_REG_4] = ARM_R4,
>
>         [BPF_REG_5] = ARM_R5,
>
>         /* callee saved registers that in-kernel function will
>         preserve */
>
>         [BPF_REG_6] = ARM_R6,
>
>         [BPF_REG_7] = ARM_R7,
>
>         [BPF_REG_8] = ARM_R8,
>
>         [BPF_REG_9] = ARM_R9,
>
>         /* Read only Frame Pointer to access Stack */
>
>         [BPF_REG_FP] = ARM_FP,
>
>         /* Temperory Register for internal BPF JIT */
>
>         [TMP_REG_1] = ARM_R11,
>
>         /* temporary register for blinding constants */
>
>         [BPF_REG_AX] = ARM_R10,
>
> };

But I have some question if anybody could help with those.

1.) Currently, as eBPF uses 64 bit registers, I am mapping 64 bit eBPF
registers with 32 bit arm registers which looks wrong to me. Do anybody
have some idea about how to map eBPF->arm 32 bit registers ?
2.) Also, is my current mapping good enough to make the JIT fast enough ?
because as you might know, eBPF JIT mostly depends on 1-to-1 mapping of
its instructions with native instructions.

Appreciate the help from anybody from the mailing list.

Best,
Shubham Bansal
