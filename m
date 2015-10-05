From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon, 5 Oct 2015 14:12:36 -0700
Message-ID: <5612E7C4.1010306@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <CAGXu5j+s+3Z6=WKKNGouNijNKcrq5o_n9-BD85Nabd-_GtL+ag@mail.gmail.com>
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
In-Reply-To: <CAGXu5j+s+3Z6=WKKNGouNijNKcrq5o_n9-BD85Nabd-_GtL+ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/15 2:00 PM, Kees Cook wrote:
> On Mon, Oct 5, 2015 at 1:48 PM, Alexei Starovoitov<ast@plumgrid.com>  wrote:
>> >In order to let unprivileged users load and execute eBPF programs
>> >teach verifier to prevent pointer leaks.
>> >Verifier will prevent
>> >- any arithmetic on pointers
>> >   (except R10+Imm which is used to compute stack addresses)
>> >- comparison of pointers
>> >- passing pointers to helper functions
>> >- indirectly passing pointers in stack to helper functions
>> >- returning pointer from bpf program
>> >- storing pointers into ctx or maps
> Does the arithmetic restriction include using a pointer as an index to
> a maps-based tail call? I'm still worried about pointer-based
> side-effects.

the array maps that hold FDs (BPF_MAP_TYPE_PROG_ARRAY and
BPF_MAP_TYPE_PERF_EVENT_ARRAY) don't have lookup/update accessors
from the program side, so programs cannot see or manipulate
those pointers.
For the former only bpf_tail_call() is allowed that takes integer
index and jumps to it. And the latter map accessed with
bpf_perf_event_read() that also takes index only (this helper
is not available to socket filters anyway).
Also bpf_tail_call() can only jump to the program of the same type.
So I'm quite certain it's safe.

Yes, please ask questions and try to poke holes. Now it is time.
