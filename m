From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] seccomp: fix populating a0-a5 syscall args in 32-bit x86 BPF
Date: Mon, 14 Apr 2014 23:31:51 -0700
Message-ID: <CAMEtUux-ekQdx2M0e=py81zvAGWo4r6Upxmwfvcrv739kSH_oQ@mail.gmail.com>
References: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
	<534C4179.7070704@amacapital.net>
	<20140414.162452.1169041476405438694.davem@davemloft.net>
	<CALCETrUu4zmawcn+U+ppDjK-hPGDff15jOhe5ojJU5ppEw4AzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Paris <eparis@redhat.com>,
	James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUu4zmawcn+U+ppDjK-hPGDff15jOhe5ojJU5ppEw4AzQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 1:28 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Apr 14, 2014 at 1:24 PM, David Miller <davem@davemloft.net> wrote:
>> From: Andy Lutomirski <luto@amacapital.net>
>> Date: Mon, 14 Apr 2014 13:13:45 -0700
>>
>>> I think this description is wrong.  (unsigned long *) &sd->args[1] is
>>> the right location, at least on 32-bit little-endian architectures.
>>
>> It absolutely is not.
>
> Huh?  It's a pointer to the right address, but the type is wrong.
>
> The changelog says "on 32-bit x86 (or any other 32bit arch), it would
> result in storing a0-a5 at wrong offsets in args[] member".  Unless
> I'm mistaken, this is incorrect: a0-a5 are are the correct offsets,
> but they are stored with the wrong type, so the other bits in there
> are garbage.

agree. your above description is more correct than the log.
We were focusing on the bug itself and the log came a bit misleading
as a result of multiple iterations back and forth between me and Daniel.

also the log says:
"gcc is clever and optimizes the copy away in other cases, e.g. x86_64"
since we actually checked assembler, so the fix doesn't pessimize
64-bit architectures :)
This function is in critical path for seccomp, so performance definitely
matters.

>>
>> The thing is a u64, and we must respect that type in a completely
>> portable way.
>>
>> Daniel's change is %100 correct, portable, and doesn't have any
>> ugly ifdef crap.
>>
>
> I have no problem with the patch itself.  I'm suggesting that a better
> changelog message would confuse other people reading the same patch
> less.
>
> --Andy
