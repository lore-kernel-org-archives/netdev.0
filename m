From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve
 from granting privs
Date: Tue, 10 Apr 2012 15:37:00 -0500
Message-ID: <4F8499EC.4010508@landley.net>
References: <1333051320-30872-1-git-send-email-wad@chromium.org> <1333051320-30872-2-git-send-email-wad@chromium.org> <20120406125517.77133b4e.akpm@linux-foundation.org> <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org, Andy Lutomirski <luto@amacapital.net>,
	linux-man@vger.kernel.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAObL_7EYb62o=a0ekzcDx=0TuN55A7aTYhLJbMNu2r8F0V77EA@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/06/2012 03:01 PM, Andrew Lutomirski wrote:
> On Fri, Apr 6, 2012 at 12:55 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Thu, 29 Mar 2012 15:01:46 -0500
>> Will Drewry <wad@chromium.org> wrote:
>>
>>> From: Andy Lutomirski <luto@amacapital.net>
>>>
>>> With this set, a lot of dangerous operations (chroot, unshare, etc)
>>> become a lot less dangerous because there is no possibility of
>>> subverting privileged binaries.
>>
>> The changelog doesn't explain the semantics of the new syscall.
>> There's a comment way-down-there which I guess suffices, if you hunt
>> for it.
>>
>> And the changelog doesn't explain why this is being added.  Presumably
>> seccomp_filter wants/needs this feature but whowhatwherewhenwhy?  Spell
>> it all out, please.
>>
>> The new syscall mode will be documented in the prctl manpage.  Please
>> cc linux-man@vger.kernel.org and work with Michael on getting this
>> done?
> 
> This has been bugging me for awhile.  Is there any interest in moving
> the manpages into the kernel source tree?

Not that I know of. I'm pretty sure if the guy maintaining it (Michael
Kerrisk) wanted to do that, he could have raised the issue at any time
over the past several years.

> Then there could be a
> general requirement that new APIs get documented when they're written.

Because having a Documentation directory, javadoc in the source itself
(some of which is combined with the Documentation/DocBook xml files to
form the make htmldocs output), menuconfig help text, and a whole buch
of scattered readmes does _not_ get new APIs documented as they're written.

That isn't even counting git commit comments and mailing list messages
in various web archives. Are you going to suck the linux weekly news
kernel articles into the tree (http://lwn.net/Kernel/Index)? How about
Linux Journal's complete archives going back to 2004
(http://www.linuxjournal.com/magazine)? Or the h-online and
kernelnewbies writeups? How about wikipedia pages on interesting kernel
topics? The sourceforge pages for userspace projects like lxc.sf.net or
i2c-utils? How about that device driver writing tutorial Greg KH
recorded in 2008, that's only a 2.8 gigabyte video file.  Rusty's
Unreliable Guides?  Greg KH's blog? (Heck, http://kernelplanet.org).

Speaking of videos, here's the 2011 LinuxCon Japan talks:

  http://video.linux.com/categories/2011-linuxcon-japan

And here are videos for the Consumer Electronic Linux Forum:

  http://free-electrons.com/blog/elc-2012-videos/

(and you can get 2011, 2010, 2006...)

Here are Ottawa Linux Symposium papers:

  http://kernel.org/doc/ols

Don't forget IBM Developerworks' library:

http://www.ibm.com/developerworks/linux/library/l-linux-kernel/

Have some standards documents:

http://www.opengroup.org/onlinepubs/9699919799/
http://busybox.net/~landley/c99-draft.html
http://www.unix.org/whitepapers/64bit.html
http://refspecs.linuxfoundation.org
http://t10.org/scsi-3.htm

Here's a random blog post about booting a bare metal "hello world"
program on qemu for ARM:

http://balau82.wordpress.com/2010/02/28/hello-world-for-bare-metal-arm-using-qemu/

Let's pick a topic, like the ELF loader. Here's the best introduction of
how ELF files _really_ work I've seen:

http://muppetlabs.com/~breadbox/software/tiny/teensy.html

Although http://linuxjournal.com/article/1059 is pretty good too, as
were http://linuxjournal.com/article/1060 and
http://linuxjournal.com/article/80 as well.  And if you want the
_details_, here's an extremely dry online book:

http;//www.iecc.com/linker/

And here's the first entry in the blog series the guy who wrote "gold"
did about writing his new linker:

http://www.airs.com/blog/archives/38

And so on, and so forth...

> (There are plenty of barely- or incompletely-documented syscalls.
> futex and relatives come to mind.)

Your proposal does not address this problem.

speaking of syscalls, I do note that ever since I tried to add Hexagon
support to strace (less fun than it sounds), I've wanted a way to beat
proper syscall information out of the kernel headers so I could get not
just syscall numbers but how many arguments and a brief stab at the type
of each argument.

Of course you _can_ get argument type and count, but not from the
headers: you have to use moderately horrible sed on the kernel's source
code, ala:

find . -name "*.c" -print0 | \
xargs -n1 -0 sed -n -e 's/.*\(SYSCALL_DEFINE[0-9](\)/\1/' \
  -e 't got;d;:got;s/).*/)/p;t;N;b got'

> --Andy

Rob
-- 
GNU/Linux isn't: Linux=GPLv2, GNU=GPLv3+, they can't share code.
Either it's "mere aggregation", or a license violation.  Pick one.
