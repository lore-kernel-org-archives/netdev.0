From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 14:01:09 -0600
Message-ID: <CABqD9hZjpxE4V3cMSNYbECbPDMHyXfgFTr+Y3_fv20MivqQJ-w@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-5-git-send-email-wad@chromium.org>
	<38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
	<CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
	<4F4547C6.8050001@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F4547C6.8050001@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 1:53 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/22/2012 11:47 AM, Will Drewry wrote:
>>>
>>> I highly disagree with every filter having to check the mode: Filte=
rs that
>>> don't check the arch on e.g. x86 are buggy, so they have to check i=
t, even
>>> if it's a 32-bit or 64-bit only system, the filters can't know that=
 and
>>> needs to check the arch at every syscall entry. All other info in t=
he data
>>> depends on the arch, because of this there isn't much code to share=
 between
>>> the two archs, so you can as well have one filter for each arch.
>>>
>>> Alternative approach: Tell the arch at filter install time and only=
 run the
>>> filters with the same arch as the current system call. If no filter=
s are run,
>>> deny the systemcall.
>>
>> This was roughly how I first implemented compat and non-compat
>> support. =A0It causes some implicit behavior across inheritance that=
 is
>> not nice though.
>>
>
> This is trivially doable at the BPF level, right? =A0Just make this t=
he
> first instruction in the program (either deny or jump to a separate
> program branch)... and then there is still "one program" without any
> weird inheritance issues?

Exactly, and that's what the patch does now (after your feedback :)

ld arch
je arch, 1, 0
ret SECCOMP_RET_KILL
<rest of bpf program>

At this point, I don't think it makes sense to do it a different way
than just in the BPF program even if it does mean leaving out the
check could leave the program open to compat-style bugs.  At least a
shared library and/or good practices should be able to catch that
error.

thanks!
will
