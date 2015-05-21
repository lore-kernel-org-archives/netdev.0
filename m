From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Thu, 21 May 2015 09:43:05 -0700
Message-ID: <CALCETrX7xAuRoRv7WV+LS-r_pOknQdXPpBEbFy5TqB_6eGTD5Q@mail.gmail.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
 <1432079946-9878-2-git-send-email-ast@plumgrid.com> <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com>
 <555BD2E4.5050608@plumgrid.com> <CALCETrVNwOVRJ4KH6mEo4hPq_QjTCb8mcwRf1sy5kd1nmnSZ+A@mail.gmail.com>
 <555E0A93.2020803@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555E0A93.2020803@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 21, 2015 at 9:40 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 5/21/15 9:20 AM, Andy Lutomirski wrote:
>>
>>
>> What I mean is: why do we need the interface to be "look up this index
>> in an array and just to what it references" as a single atomic
>> instruction?  Can't we break it down into first "look up this index in
>> an array" and then "do this tail call"?
>
>
> I've actually considered to do this split and do first part as map lookup
> and 2nd as 'tail call to this ptr' insn, but it turned out to be
> painful: verifier gets more complicated, ctx pointer needs to kept
> somewhere, JITs need to special case two things instead of one.
> Also I couldn't see a use case for exposing program pointer to the
> program itself. I've explored this path only because it felt more
> traditional 'goto *ptr' like, but adding new PTR_TO_PROG type to
> verifier looked wasteful.

At some point, I think that it would be worth extending the verifier
to support more general non-integral scalar types. "Pointer to
tail-call target" would be just one of them.  "Pointer to skb" might
be nice as a real first-class scalar type that lives in a register as
opposed to just being magic typed context.

We'd still need some way to stick fds into a map, but that's not
really the verifier's problem.

--Andy
