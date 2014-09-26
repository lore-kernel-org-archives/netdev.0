From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 15:41:56 -0700
Message-ID: <CALCETrUP=LE2QNzYL8LCukeuWeumOn0bm0eqYscc7GJqq45oYA@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
 <CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
 <CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
 <CAMEtUux-WFOGABTrWW=BGUstE=Zz6agXTGCGrRJtNXDfRmx-5A@mail.gmail.com>
 <CALCETrVLtJOYkHwsmwueZ7jsSgrNED564W+m4FmMZJZL-836mg@mail.gmail.com>
 <CAMEtUuxq7oNmDAHZ+1t4Vd-QhW6SV7eoM_juxXGEDJBF3Nfu6A@mail.gmail.com>
 <CALCETrWcmZVmRZARM_s9S-zZ4Xm_TcxRrzJWGwL0O9ySmVgr5A@mail.gmail.com> <CAMEtUuzQF+3uWFWmj5nSdYoJfo0W2F0wkvoyc4pP--EH3O_jYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuzQF+3uWFWmj5nSdYoJfo0W2F0wkvoyc4pP--EH3O_jYA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 3:26 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Fri, Sep 26, 2014 at 3:07 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Fri, Sep 26, 2014 at 3:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>> On Fri, Sep 26, 2014 at 2:47 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>>
>>>> Can't you just disallow the 1-byte write to the stack?
>>>
>>> of course not.
>>> That would be extremely limiting to users.
>>> Can you actually see yourself living with stack that only
>>> allows 8-byte writes/reads?
>>> The stack usage will increase a lot, since all char/short
>>> stack variables will become 8-byte...
>>
>> How about requiring that sub-8-byte stack accesses only be to integer slots?
>
> you mean to reject the sub-8-byte write early if it's going
> into space where pointers were stored?
> That will limit stack reuse.
> gcc/llvm generate code where the same stack location
> is used by different variables during life of the function.
> So if I reject the write early, it will break otherwise valid
> programs.

I think that a sub-8-byte write to an integer slot should leave it as
an integer and a sub-8-byte write to a non-integer slot should turn
that slot into an integer (if conversions to integer are permitted) or
be rejected otherwise.  gcc/llvm could emit an 8-byte write first, as
needed, to make this valid.

Alternatively, an integer stack slot could have a bitmask indicating
which bytes are valid.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
