From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: v2 of seccomp filter c/r patches
Date: Tue, 15 Sep 2015 11:13:51 -0700
Message-ID: <CALCETrVxhNvmEdMq0XRy1YZ+oJLDwcmE1y6prs7FGGhsS-Y5gg@mail.gmail.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
 <CALCETrWxLMSgdsdT9gTL80LSovONmCcTYjzqrHqF-WdJ4BN1Uw@mail.gmail.com>
 <20150911172806.GA7244@smitten> <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
 <20150915160738.GJ31864@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Oleg Nesterov <oleg@redhat.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Linux API <linux-api@vger.kernel.org>,
	Will Drewry <wad@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150915160738.GJ31864@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 15, 2015 at 9:07 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> Hi Andy,
>
> On Mon, Sep 14, 2015 at 10:52:46AM -0700, Andy Lutomirski wrote:
>>
>> I'm not sure I entirely like this solution...
>
> Ok. Since we also aren't going to do all the eBPF stuff now, how about
> something that looks like this:
>
> struct seccomp_layer {
>   unsigned int size;
>   unsigned int type; /* SECCOMP_BPF_CLASSIC or SECCOMP_EBPF or ... */
>   bool inherited;
>   union {
>     unsigned int insn_cnt;
>     struct bpf_insn *insns;
>   };
> };
>
> with a ptrace command:
>
> ptrace(PTRACE_SECCOMP_DUMP_LAYER, pid, i, &layer);
>
> If we save a pointer to the current seccomp filter on fork (if there
> is one), then I think the inherited flag is just,
>
> inherited = is_ancestor(child->seccomp.filter, child->seccomp.inherited_filter)
>

I'm lost.  What is the inherited flag for?

--Andy
