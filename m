From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v11 net-next 11/12] net: filter: move eBPF instruction
 macros
Date: Thu, 11 Sep 2014 08:29:49 +0200
Message-ID: <5411415D.4060103@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <1410325808-3657-12-git-send-email-ast@plumgrid.com> <54103506.1030501@redhat.com> <CAMEtUuwQXj=oWzyBkogTSfOAhjhx0oyB5gC4+HoccTGWg8Obfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwQXj=oWzyBkogTSfOAhjhx0oyB5gC4+HoccTGWg8Obfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 08:16 PM, Alexei Starovoitov wrote:
> On Wed, Sep 10, 2014 at 4:24 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 09/10/2014 07:10 AM, Alexei Starovoitov wrote:
>>>
>>> move instruction macros (like BPF_MOV64_REG or BPF_ALU32_IMM)
>>> from linux/filter.h into uapi/linux/bpf.h
>>> so that userspace programs can use them.
>>>
>>> verifier testsuite (in later patches) will be using them.
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>
>> I don't think we need this commit at all. These macros are not really
>> part of the ABI and we should expose __as less as possible__, otherwise
>> we won't be able to alter them anymore. Plus, based on your previous
>> argumentation regarding the header file expose, we also won't be able
>> to add any new macros anymore since you could run into name collisions.
>>
>> Anyway, I don't see a reason why a e.g. central user space eBPF library
>> cannot live with, for example, a private copy of these helper macros or
>> whatever it wants to define by itself.
>>
>> I know in classic BPF there's BPF_STMT() and BPF_JUMP() but it's much
>> less complicated than eBPF and less likely to changes.
>
> Interesting idea. Are you saying just copy paste these
> 226 lines into user libbpf.h for now to use them in testsuite
> and examples ? Hmm.
> Indeed the less lines we add to uapi the better. I'll do that.

Yes, that should be just fine, the existing ABI is not allowed to
change anyway and we're running into less pain if we decide to change
existing or add new macros internally.
