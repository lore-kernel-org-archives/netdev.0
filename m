From: Markus Gutschke <markus@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 13:28:49 -0800
Message-ID: <CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
 <1329422549-16407-3-git-send-email-wad@chromium.org> <4F3D61CB.2000301@zytor.com>
 <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com> <4F3D7250.6040504@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <4F3D7250.6040504@zytor.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 13:17, H. Peter Anvin <hpa@zytor.com> wrote:
> The other thing that you really need in addition to system call numbe=
r is
> ABI identifier, since a syscall number may mean different things for
> different entry points. =C2=A0For example, on x86-64 system call numb=
er 4 is
> write() if called via int $0x80 but stat() if called via syscall64. T=
his is
> a local property of the system call, not a global per process.

I think, the documentation said that as soon as prctl() is used to set
a bpf filter for system calls, it automatically disallows system calls
using an entry point other than the one used by this particular
prctl().

I was trying to come up with scenarios where this particular approach
causes problem, but I can't think of any off the top of my head. So,
it might actually turn out to be a very elegant way to reduce the
attack surface of the kernel. If we are really worried about userspace
compatibility, we could make the kernel send a signal instead of
terminating the program, if the wrong entry point was used; not sure
if that is needed, though.


Markus
