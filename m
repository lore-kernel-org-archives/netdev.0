From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2 net-next 2/3] x86: bpf_jit_comp: support
 BPF_S_ANC_SECCOMP_LD_W instruction
Date: Mon, 29 Apr 2013 03:48:29 -0400
Message-ID: <CAKU6vyaWgj4kKq0pBUYHa2hDMDOgtVghCWqpaD7riVe+KduOUA@mail.gmail.com>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
 <1367029047-14830-3-git-send-email-xi.wang@gmail.com> <1367112092.8964.294.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367112092.8964.294.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 27, 2013 at 9:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I would feel more comfortable if you added :
>
>         if (seen & SEEN_DATAREF) {
>                 pr_err_once("SECCOMP_LD_W assertion failed\n"):
>                 goto out;
>         }
>
> This way, if BPF is changed in the future, but not the x86 JIT, we
> can have a working kernel.
>
> Ideally, we should add a SEEN_SKBREF to make sure rdi value can be
> scratched, or you just push %rdi/pop %rdi, its only one byte
> instructions.

Adding SEEN_SKBREF sounds like a good idea. :)

> Or completely optimize the thing and not call seccomp_bpf_load() at all.

This would be cool.

> (current would be loaded once in r9, task_pt_regs() would be loaded once
> in r8)

Both syscall_get_arch() and syscall_get_arguments() need to test for
the TS_COMPAT bit (in task_thread_info(current)->status); we should
load that once, too.

Thanks for the comments.  Will try a v3.

- xi
