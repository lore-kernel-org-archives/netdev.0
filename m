From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 15:51:23 -0600
Message-ID: <CABqD9haWxRLac1w3m9rSmyDvcg8jxYcxdmAAsgB7pEEBMHr=2g@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<4F3D61CB.2000301@zytor.com>
	<CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
	<4F3D7250.6040504@zytor.com>
	<CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com>
	<4F3D766E.7040205@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Markus Gutschke <markus@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <4F3D766E.7040205@zytor.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 3:34 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 01:28 PM, Markus Gutschke wrote:
>>
>> I think, the documentation said that as soon as prctl() is used to set
>> a bpf filter for system calls, it automatically disallows system calls
>> using an entry point other than the one used by this particular
>> prctl().
>>
>> I was trying to come up with scenarios where this particular approach
>> causes problem, but I can't think of any off the top of my head. So,
>> it might actually turn out to be a very elegant way to reduce the
>> attack surface of the kernel. If we are really worried about userspace
>> compatibility, we could make the kernel send a signal instead of
>> terminating the program, if the wrong entry point was used; not sure
>> if that is needed, though.
>>
>
> Let's see... we're building an entire pattern-matching engine and then
> randomly disallowing its use because we didn't build in the right bits?
>
> Sorry, that's asinine.
>
> Put the bloody bit in there and let the pattern program make that decision.

Easy enough to add a bit for the mode: 32-bit or 64-bit.  It seemed
like a waste of cycles for every 32-bit program or every 64-bit
program to check to see that its calling convention hadn't changed,
but it does take away a valid decision the pattern program should be
making.

I'll add a flag for 32bit/64bit while cleaning up seccomp_data. I
think that will properly encapsulate the is_compat_task() behavior in
a way that is stable for compat and non-compat tasks to use.  If
there's a more obvious way, I'm all ears.

thanks!
will
