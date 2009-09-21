From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Mon, 21 Sep 2009 15:18:43 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909211456180.1116@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <200909190000.43556.agruen@suse.de> <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com> <200909212204.51077.agruen@suse.de> <20090921202823.GB14700@shareable.org>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754092AbZIUWSn@vger.kernel.org>
In-Reply-To: <20090921202823.GB14700@shareable.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Sep 2009, Jamie Lokier wrote:

> I think so to, and that'd be a great all round solution.

If this is for anti-malware vendors to intercept userspace accesses 
they're currently doing it by hacking the syscall table, why don't we 
offer a way to monitor syscalls (kernel side) in a non racy way?
Modules can [un]register themselves for syscall intercaption, and receive 
the syscall number and parameters. They'd be able to change paramters, 
return error codes, and so on.
The cost of the check in the syscall path could even be under an 
alternative-like patching, if really neeeded.
The Pros of this would be:

- The kernel code to implement this would be trivially small, with no 
  I-need-this-feature-too growth potential

- There won't be any externally visible API to maintain (and its kernel 
  counter part) and expand

- Any system call can be intercepted, allowing it to be flexible while 
  leaving the burden of the interception handling, and communication with 
  userspace policy enforcers, to the anti-malware (or whoever really) 
  companies modules

The anti-malware are already doing this (intercepting syscall), they 
already have code for it, and they always did (writing kernel 
modules/drivers, that is) for Windows.



- Davide
