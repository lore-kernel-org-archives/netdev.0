From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 15:33:47 -0600
Message-ID: <CABqD9hbW_z-x7tgnBHPqVry=XLo+HDFtAhdXKHG+fxgn6fB6_g@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-5-git-send-email-wad@chromium.org>
	<CAE6n16mCrJC=Sre+PT1H_VfSjW0MGyi0xtEcdcRvGMvvwXWzmA@mail.gmail.com>
	<CABqD9hZSLqn+=jr6sWwp_eJ5WsuGpH2Khoc_7aRmYt+1ZaEGoA@mail.gmail.com>
	<4F3D7500.2070604@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F3D7500.2070604@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 3:28 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 12:42 PM, Will Drewry wrote:
>> On Thu, Feb 16, 2012 at 2:24 PM, Markus Gutschke <markus@chromium.or=
g> wrote:
>>> SIGTRAP might not be the ideal choice of signal number, as it can m=
ake it
>>> very difficult to debug the program in gdb.
>>
>> True enough. =A0In theory, we could use the lower 16-bits of the ret=
urn
>> value to let the bpf program set a signal, but not all signals are
>> masked synchronous and those that are probably get gdb's attention,
>> just not a severely :) (ILL, SEGV, BUS, TRAP, FPE). Perhaps SIGILL i=
s
>> a logically appropriate option -- or letting the api user decide fro=
m
>> the SYNCHRONOUS_MASK set. =A0I'm open to whatever makes sense, thoug=
h.
>> (I wasn't even sure if it was kosher to add a new TRAP_SECCOMP value=
=2E)
>>
>
> There is a standard signal for this -- SIGSYS -- which happens to be
> currently unused in Linux.

Awesome.  I'll respin using that.
