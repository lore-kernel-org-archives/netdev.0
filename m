From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Fri, 17 Feb 2012 02:25:55 +0100
Message-ID: <eab10cc7834be3c720147a6b24769840.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <1329422549-16407-3-git-send-email-wad@chromium.org>
    <4F3D61CB.2000301@zytor.com>
    <CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
    <4F3D7250.6040504@zytor.com>
    <501858544d264abc6526f2b25a224f2b.squirrel@webmail.greenhost.nl>
    <CAObL_7G7CvCVgjR-JYjNDi_Sy65UHXaqas4-sQCVej-4bX2PJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Will Drewry" <wad@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: "Andrew Lutomirski" <luto@mit.edu>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAObL_7G7CvCVgjR-JYjNDi_Sy65UHXaqas4-sQCVej-4bX2PJA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, February 17, 2012 01:51, Andrew Lutomirski wrote:
> IMO the best solution is to have the One True Seccomp Filter Compiler
> (tm).  It would handle multiple namespaces, cross-arch differences,
> and such, and it would do it correctly.  It could live in the kernel
> tree.

I'm not interested in any such compiler, if I use this BPF thing I'll use
it directly by scanning my syscall table info and converting it to a BPF
filter for the cases where it's possible. This code will be cross-platform,
all the platform dependent info comes from the syscall table.

It seems I'll just build a bitmask telling what to do for each syscall,
with special cases for the few syscalls that can be handled totally within
BPF by checking the arguments.

My total lines of code is 5k now, I'm not going to use a complex thousands
of lines, badly tested, probably buggy compiler just for BPF support.

> Without something like that or an incredible amount of special care,
> actual portability is probably a pipe dream.

The filter programs are already platform dependent because of the syscall
numbers and sometimes args differences. But that is no reason to make it
even less cross-platform.

Your OTSF compiler won't be able to handle different modes other than
adding a check at the start and having totally orthogonal codes for the
different cases. You can as well have separate filters then. Any other
approach dies because of the added complexity or will be a lot slower.

Greetings,

Indan
