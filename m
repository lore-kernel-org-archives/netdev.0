From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v12 06/13] seccomp: add system call filtering using BPF
Date: Fri, 2 Mar 2012 07:43:50 +0100
Message-ID: <bc1b4ec8fbad5a5931a928f108a6095f.squirrel@webmail.greenhost.nl>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
    <1330559620-23543-6-git-send-email-wad@chromium.org>
    <a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>
    <4F50603B.7040505@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F50603B.7040505@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, March 2, 2012 06:52, H. Peter Anvin wrote:
> On 03/01/2012 09:45 PM, Indan Zupancic wrote:
>>
>>> + * @nr: the system call number
>>> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
>>> + *        as defined in <linux/audit.h>.
>>> + * @instruction_pointer: at the time of the system call.
>>
>> If the vDSO is used this will always be the same, so what good is this?
>> I haven't gotten an answer to this yet.
>>
>
> And if it isn't, or you're on an architecture which doesn't use the vdso
> as the launching point, it's not.

True, but then what?

> You seem to be unable to look outside
> your own particular use cases, but it is very likely that the same
> oddball cases which do mixed-mode programming are ones for which this
> kind of filtering facility would be extremely useful

The filtering code has no way of reading the instruction, so it can't
know if it's a good or bad one. And the mode is passed via 'arch' already,
which is the proper way of checking this.

To properly protect the ptrace user against unexpected modes it's better
to provide a way to the filter to know the task mode instead of trying
to figure it out from IP.

I'm not saying having the IP is never useful, I actually use it in my
ptrace code (and have to add IP checks to handle those odd mixed mode
cases). I just don't see how it can be used by a BPF filter.

> -- Pin is a great example.

Is that http://www.pintool.org/?

Can you explain how knowing the IP is useful for Pin?

All I am asking for is just one use case for providing the IP. Is that
asking for too much?

Because the only one I can think of creates a false sense of security:

"Oh, the IP comes from a trusted code area, so it must be fine."

And the problem with that is that the IP doesn't say anything about the
call path, only where the last instruction was. Address randomization
helps a little bit, but it's not a guarantee.

Greetings,

Indan


