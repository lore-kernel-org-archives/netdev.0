From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs
 and verifier testsuite
Date: Wed, 10 Sep 2014 13:35:18 +0200
Message-ID: <54103776.3080706@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <1410325808-3657-13-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410325808-3657-13-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 07:10 AM, Alexei Starovoitov wrote:
> 1.
> the library includes a trivial set of BPF syscall wrappers:
> int bpf_create_map(int key_size, int value_size, int max_entries);
> int bpf_update_elem(int fd, void *key, void *value);
> int bpf_lookup_elem(int fd, void *key, void *value);
> int bpf_delete_elem(int fd, void *key);
> int bpf_get_next_key(int fd, void *key, void *next_key);
> int bpf_prog_load(enum bpf_prog_type prog_type,
> 		  const struct sock_filter_int *insns, int insn_len,
> 		  const char *license);
> bpf_prog_load() stores verifier log into global bpf_log_buf[] array
>
> 2.
> test stubs configure eBPF infra with 'unspec' map and program types.
> These are fake types used by user space testsuite only.
>
> 3.
> verifier tests valid and invalid programs and expects predefined
> error log messages from kernel.
> 40 tests so far.
>
> $ sudo ./test_verifier
>   #0 add+sub+mul OK
>   #1 unreachable OK
>   #2 unreachable2 OK
>   #3 out of range jump OK
>   #4 out of range jump2 OK
>   #5 test1 ld_imm64 OK
>   ...
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>

Since we already have an extensive BPF test suite, that is, lib/test_bpf.c,
which currently also does sanity checks for the classic BPF verifier, is
there a reason these verifier test cases cannot be extended/integrated there
as well but have to go to kernel/bpf/test_stub.c resp. samples/bpf/test_verifier.c ?
I don't like that we put testing code into kernel/bpf/ whereas we already
have a BPF test infrastructure in the kernel elsewhere.
