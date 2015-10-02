From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next V2] ARM: net: support BPF_ALU | BPF_MOD
 instructions in the BPF JIT.
Date: Fri, 2 Oct 2015 08:25:20 -0700
Message-ID: <20151002152519.GA1619@Alexeis-MBP.westell.com>
References: <1443798407-19154-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443798407-19154-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2015 at 05:06:47PM +0200, Nicolas Schichan wrote:
> For ARMv7 with UDIV instruction support, generate an UDIV instruction
> followed by an MLS instruction.
> 
> For other ARM variants, generate code calling a C wrapper similar to
> the jit_udiv() function used for BPF_ALU | BPF_DIV instructions.
> 
> Some performance numbers reported by the test_bpf module (the duration
> per filter run is reported in nanoseconds, between "jitted:<x>" and
> "PASS":
> 
> ARMv7 QEMU nojit:	test_bpf: #3 DIV_MOD_KX jited:0 2196 PASS
> ARMv7 QEMU jit:		test_bpf: #3 DIV_MOD_KX jited:1 104 PASS
> ARMv5 QEMU nojit:	test_bpf: #3 DIV_MOD_KX jited:0 2176 PASS
> ARMv5 QEMU jit:		test_bpf: #3 DIV_MOD_KX jited:1 1104 PASS
> ARMv5 kirkwood nojit:	test_bpf: #3 DIV_MOD_KX jited:0 1103 PASS
> ARMv5 kirkwood jit:	test_bpf: #3 DIV_MOD_KX jited:1 311 PASS
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

run-time check for zero is there, so looks good to me
Acked-by: Alexei Starovoitov <ast@kernel.org>
