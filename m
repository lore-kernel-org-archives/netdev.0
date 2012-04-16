From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Mon, 16 Apr 2012 14:11:07 -0500
Message-ID: <4F8C6ECB.8000206@landley.net>
References: <1333051320-30872-1-git-send-email-wad@chromium.org> <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406125517.77133b4e.akpm@linux-foundation.org> <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com> <20120406142824.61d8ca3b@lwn.net> <CAKgNAkhhnC1+vdh7vTYKkngzxHccDwHH_aKF5wCNhga33BGhyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>, Andrew Lutomirski <luto@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>,
	linux-man@vger.kernel.org
To: mtk.manpages@gmail.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAKgNAkhhnC1+vdh7vTYKkngzxHccDwHH_aKF5wCNhga33BGhyQ@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2012 02:31 PM, Michael Kerrisk (man-pages) wrote:
> On Sat, Apr 7, 2012 at 8:28 AM, Jonathan Corbet <corbet@lwn.net> wrote:
>> On Fri, 6 Apr 2012 13:01:17 -0700
>> Andrew Lutomirski <luto@mit.edu> wrote:
>>
>>> This has been bugging me for awhile.  Is there any interest in moving
>>> the manpages into the kernel source tree?  Then there could be a
>>> general requirement that new APIs get documented when they're written.
>>
>> Man page (or other documentation) requirements for patch acceptance are a
>> regular kernel summit feature.  People seem to think it's a good idea, but
>> actual enforcement of such requirements always seems to be lacking.  Lots
>> of people have kind of given up trying.  I don't really see that adding
>> the man pages to the tree would help, but I could be wrong...
> 
> I largely consider this (moving man pages to kernel.org) a technical
> solution to what is fundamentally a social problem (developers
> reluctant to write documentation), and doubt that the technical
> solution would make much difference.

*nod* *nod*

> I'd love to be proved wrong, but
> the experiment would require significant start-up effort. (My
> collected thoughts on this can be found here:
> http://www.kernel.org/doc/man-pages/todo.html#migrate_to_kernel_source.
> Note the alternative idea of patch tags mentioned at the end of that
> text.)
> 
> Unless, or until there's a paid maintainer, I don't expect things to
> get significantly better than what they currently are.

Maintainer of which, the man pages or the kernel Documentation directory?

I just got handed the Documentation ball (right as relatives were
visiting and a couple days before buying a new house, so I've just put
_tons_ of time into it so far). I have grandiose plans for cleaning it
up, but first I need to get my kernel.org account working again.

That said, I think having man-pages in the kernel directory is a bad
idea, for reasons I already posted to this thread.

> The quite
> significant improvements in man-pages since 2004, when I became
> maintainer were in small part due to the fact that I was for a short
> period paid to do the work, but in much larger part due to a huge
> private effort over those years which over the last couple of years is
> no longer unsustainable for me (man-pages is in competition with
> requirements for my attention from family, working life, and
> (seriously!) seismic events),

Heh, I know the feeling. :)

Circa 2007 I was paid to work on documentation for half a year (hence
the http://kernel.org/doc directory I stopped being able to update when
kernel.org got hacked). These days it competes with my toybox and
aboriginal linux projects, and with my day job.

The way I'm looking at it is I'm _curating_ documentation.  I'm acting
as some kind of of librarian, and my first goal is reshuffling the files
in Documentation into some semblance of order so you can see what's
there.  (I've posted about that before here, moving
architecture-specific stuff under an arch subdirectory and so on.)

I do sometimes write new documentation, but no human being knows
everything there is to know about the kernel. Building expertise is
enormously time consuming,

That said, if anything was going to move into the kernel moving the
syscall info into javadoc might make sense.

Something that might help you is the syscall mining script snippet I
posted last time:

find . -name "*.c" -print0 | \
xargs -n1 -0 sed -n -e 's/.*\(SYSCALL_DEFINE[0-9](\)/\1/' \
  -e 't got;d;:got;s/).*/)/p;t;N;b got'

I might be able to build a script around that which would look up the
system call number, figure out which architectures implement this call,
find any javadoc at the call site, and so on. That way we could automate
this a bit.  For example, kernel/fork.c has two syscalls:

SYSCALL_DEFINE1(set_tid_address, int __user *, tidptr)

/*
 * unshare allows a process to 'unshare' part of the process
 * context which was originally shared using clone.  copy_*
 * functions used by do_fork() cannot be used here directly
 * because they modify an inactive task_struct that is being
 * constructed. Here we are modifying the current, active,
 * task_struct.
 */
SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)

Both of these have man pages which provide way more info than the
comments (if any). Is there any sort of javadoc comment before the
syscall that might provide useful information you could automatically
harvest?  Some sort of standard header briefly defining the syscall?

(P.S. Speaking of man 2 unshare, what's with the #define _GNU_SOURCE for
a new linux kernel syscall? What the heck does the FSF have to do with
anything? This didn't used to be needed in ubuntu 10.04 but then the
headers changed to match the man page, which I found sad...)

> Cheers,
> 
> Michael

Rob
-- 
GNU/Linux isn't: Linux=GPLv2, GNU=GPLv3+, they can't share code.
Either it's "mere aggregation", or a license violation.  Pick one.
