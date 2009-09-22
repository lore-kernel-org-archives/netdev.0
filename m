From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 07:51:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <200909190000.43556.agruen@suse.de> <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com> <200909212204.51077.agruen@suse.de> <20090921202823.GB14700@shareable.org> <alpine.DEB.2.00.0909211456180.1116@makko.or.mcafeemobile.com>
 <20090921231227.GJ14700@shareable.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090921231227.GJ14700@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Sep 2009, Jamie Lokier wrote:

> I don't mind at all if fanotify is replaced by a general purpose "take
> over the system call table" solution ...

That was not what I meant ;)
You'd register/unregister as syscall interceptor, receiving syscall number 
and parameters, you'd be able to return status/error codes directly, and 
you'd have the ability to eventually change the parameters. All this 
should be pretty trivial code, and at the same time give full syscall 
visibility to the modules.
The complexity would be left to the interceptors, as they already do it 
today.



> But I can't help noticing that we _already_ have quite well placed
> hooks for intercepting system calls, called security_this and
> security_that (SELinux etc), ...

That has "some" limits WRT non-GPL modules and relative static linkage.



> However, being a little kinder, I suspect even the anti-malware
> vendors would rather not slow down everything with race-prone
> complicated tracking of everything every process does...  which is why
> fanotify allows it's "interest set" to be reduced from everything to a
> subset of files, and it's results to be cached, and let the races be
> handled in the normal way by VFS.

They are already doing it today, since they are forced to literally find 
and hack the syscall table.
They already have things like process whitelists, path whitelists, scan 
caches, and all the whistles, in their code.
Of course, some of them might be interested in pushing given complexity 
inside the kernel, since they won't have to maintain it.
Some other OTOH, might be interested in keeping a syscall-based access, 
since they already have working code based on that abstraction.
The good part of this would be that all the userspace communication API, 
whitelists, caches, etc...  would be left to the module implementors, and 
not pushed inside the kernel.
That, and the flexibility of being able to intercept all the userspace 
entrances into the kernel.



- Davide


