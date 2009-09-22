From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 09:04:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <20090921231227.GJ14700@shareable.org> <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com> <200909221731.34717.agruen@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamie Lokier <jamie@shareable.org>, Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756972AbZIVQEp@vger.kernel.org>
In-Reply-To: <200909221731.34717.agruen@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Sep 2009, Andreas Gruenbacher wrote:

> The fatal flaw of syscall interception is race conditions: you look up a 
> pathname in your interception layer; then when you call into the proper 
> syscall, the kernel again looks up the same pathname. There is no way to 
> guarantee that you end up at the same object in both lookups. The security 
> and fsnotify hooks are placed in the appropriate spots to avoid exactly that.

Fatal? You mean, for this corner case that the anti-malware industry lived 
with for so much time (in Linux and Windows), you're prepared in pushing 
all the logic that is currently implemented into their modules, into the 
kernel?
This includes process whitelisting, path whitelisting, caches, userspace 
access API definition, and so on? On top of providing a generally more 
limited interception.
Why don't we instead offer a lower and broader level of interception, 
letting the users decide if such fatal flaw needs to be addressed or 
not, in their modules?
They get a broader inteception layer, with the option to decide if or if 
not address certain scenarios, and we get less code inside the kernel.
A win/win situation, if you ask me.


- Davide
