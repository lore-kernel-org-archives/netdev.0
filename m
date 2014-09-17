From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs
 and verifier testsuite
Date: Wed, 17 Sep 2014 09:16:18 +0200
Message-ID: <54193542.6080101@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <1410325808-3657-13-git-send-email-ast@plumgrid.com> <54103776.3080706@redhat.com> <CAMEtUuzEQu30WiYprRcDBogJxxrDeNhvn=kF+z8cVvhR-vjTQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
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
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzEQu30WiYprRcDBogJxxrDeNhvn=kF+z8cVvhR-vjTQg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 08:08 PM, Alexei Starovoitov wrote:
> On Wed, Sep 10, 2014 at 4:35 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> Since we already have an extensive BPF test suite, that is, lib/test_bpf.c,
>> which currently also does sanity checks for the classic BPF verifier, is
>> there a reason these verifier test cases cannot be extended/integrated there
>> as well but have to go to kernel/bpf/test_stub.c resp.
>> samples/bpf/test_verifier.c ?
>> I don't like that we put testing code into kernel/bpf/ whereas we already
>> have a BPF test infrastructure in the kernel elsewhere.
>
> yes. there is a reason. Verifier needs to be tested from user space,
> since it works on fds. Process local map_fd are part of the eBPF
> programs. Therefore one is testing things from kernel and
> another from userspace. We definitely need both.
> Currently there is no use case to call verifier from inside
> the kernel. I'm not sure there will be one. Verifier's main
> purpose is to check user supplied programs and provide
> humans an understandable error messages of what
> is 'unsafe' in particular program.
> Eventually we will integrate this verifier messages with
> program compilation. Like, the user would write a program
> in C then invoke a wrapper of compiler and verifier, which
> will point to lines in C code which are doing something
> wrong like loops or out of bounds access. Currently verifier
> complains about particular 'unsafe' instruction, but
> humans have hard time correlating asm to C.

That actually still doesn't answer my question why the test stub
cannot live in lib/test_bpf where we have our actual testing
framework for eBPF/BPF, also since you exactly only build test_stub.c
when TEST_BPF is enabled which is the Kconfig for lib/test_bpf.
