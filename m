From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect
 negative mem references
Date: Wed, 28 Mar 2012 22:05:29 +0200
Message-ID: <1332965129.2325.12.camel@edumazet-glaptop>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-03-28 at 21:15 +0200, Jan Seiffert wrote:
> Consider the following test program:
> 
> #include <stdio.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <pcap-bpf.h>
> 
> #define die(x) do {perror(x); return 1;} while (0)
> struct bpf_insn udp_filter[] = {
> 	/*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(0)), /* leax	net[0] */
> 	/*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_IND, 0),             /* ldb	[x+0] */
> 	/*   2 */ BPF_STMT(BPF_RET|BPF_A, 0),                    /* ret	a */
> };

When this point was raised some weeks ago, we wanted to see a _real_ use
of negative mem reference.

You provide a test program but what this filter is supposed to do
exactly ?
