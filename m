From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon, 5 Oct 2015 17:28:04 -0700
Message-ID: <56131594.6080801@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <CAGXu5j+s+3Z6=WKKNGouNijNKcrq5o_n9-BD85Nabd-_GtL+ag@mail.gmail.com>
 <5612E7C4.1010306@plumgrid.com>
 <CAGXu5jKTDzMXXYJdWdP=b4fABu_b5ifjv88RVMgBkiR=_JUAog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jKTDzMXXYJdWdP=b4fABu_b5ifjv88RVMgBkiR=_JUAog@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/15 3:02 PM, Kees Cook wrote:
>> the array maps that hold FDs (BPF_MAP_TYPE_PROG_ARRAY and
>> >BPF_MAP_TYPE_PERF_EVENT_ARRAY) don't have lookup/update accessors
>> >from the program side, so programs cannot see or manipulate
>> >those pointers.
>> >For the former only bpf_tail_call() is allowed that takes integer
>> >index and jumps to it. And the latter map accessed with
> Okay, so I can't take a pointer, put it on the stack, take it back any
> part of it as an integer and use it for a tail call?

not quite.
you can store a pointer to stack and read it as 8 byte load back into
another register, but reading <8 byte of it will be rejected.
That's the test:
unpriv: read pointer from stack in small chunks
we obviously want to avoid hiding pointer in integers.
After reading it back from stack as a pointer you cannnot use
this register to pass as index into bpf_tail_call().
That's the test:
unpriv: pass pointer to helper function

please keep shooting everything that comes to mind.
