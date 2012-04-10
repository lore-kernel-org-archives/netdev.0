From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Tue, 10 Apr 2012 13:00:17 -0700
Message-ID: <20120410130017.0d20e1b2.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
	<CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Apr 2012 14:59:00 -0500
Will Drewry <wad@chromium.org> wrote:

> >> I think this gives userspace an easy way of causing page allocation
> >> failure warnings, by permitting large kmalloc() attempts. __Add
> >> __GFP_NOWARN?
> >
> > Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
> > it allocates up to 512kb before even checking the length.
> >
> > What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) instead?
> 
> It looks like GFP_USER|__GFP_NOWARN would make sense here.  I'll change it.

I'm not really sure why GFP_USER exists.  It's very rarely used, and
most usages are probably inappropriate.  To me it means "same as
GFP_HIGHUSER, only don't use highmem".  That's relevant to blockdev
pagecache and nothing else as far as I can tell.  And good luck working
out what the __GFP_HARDWALL does ;)

This is a regular old allocation of kernel memory - the thing to use
here is GFP_KERNEL|__GFP_NOWARN.

(I'm surprised that we didn't remove __GFP_NOWARN ages ago - warning by
default is pretty obnoxious.  But the warning continues to be
occasionally useful and false positives are rare).
