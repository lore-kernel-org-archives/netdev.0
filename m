From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Thu, 11 Sep 2014 21:47:14 +0200
Message-ID: <5411FC42.3070505@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <541013CE.6020307@redhat.com> <CAMEtUuwrHX4ENK9cZ0C+XVB=wkMz1=wLphX_GVLvd8pyJKMXeQ@mail.gmail.com>
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
In-Reply-To: <CAMEtUuwrHX4ENK9cZ0C+XVB=wkMz1=wLphX_GVLvd8pyJKMXeQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 07:32 PM, Alexei Starovoitov wrote:
> On Wed, Sep 10, 2014 at 2:03 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>>              struct { /* anonymous struct used by BPF_PROG_LOAD command */
>>>                  enum bpf_prog_type    prog_type;
>>>                  __u32                 insn_cnt;
>>>                  const struct bpf_insn *insns;
>>>                  const char            *license;
>>>                  __u32                 log_level; /* verbosity level of
>>> eBPF verifier */
>>>                  __u32                 log_size;  /* size of user buffer */
>>>                  void                  *log_buf;  /* user supplied buffer
>>> */
>>
>>
>> What is log buffer? Would that mean the verifier will return an error
>> string if the program will not pass it, or if not, what other data?
>> I think the man page is missing how to examine the returned verifier
>> log buffer data.
>
> yes. it's an error log (as text string for humans) from verifier.

I was confused due to the void pointer. But that also means that the text
string becomes part of the ABI; aren't eBPF specific error codes (perhaps
a tuple of [line + error code]), though ugly as well, but perhaps the better
solution to this [which user space can then map to an actual string]?
