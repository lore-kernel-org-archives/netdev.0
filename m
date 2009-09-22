From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 17:31:34 +0200
Message-ID: <200909221731.34717.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <20090921231227.GJ14700@shareable.org> <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>, Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756851AbZIVPcp@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 22 September 2009 16:51:39 Davide Libenzi wrote:
> On Tue, 22 Sep 2009, Jamie Lokier wrote:
> > I don't mind at all if fanotify is replaced by a general purpose "take
> > over the system call table" solution ...
>
> That was not what I meant ;)
> You'd register/unregister as syscall interceptor, receiving syscall number
> and parameters, you'd be able to return status/error codes directly, and
> you'd have the ability to eventually change the parameters. All this
> should be pretty trivial code, and at the same time give full syscall
> visibility to the modules.

The fatal flaw of syscall interception is race conditions: you look up a 
pathname in your interception layer; then when you call into the proper 
syscall, the kernel again looks up the same pathname. There is no way to 
guarantee that you end up at the same object in both lookups. The security 
and fsnotify hooks are placed in the appropriate spots to avoid exactly that.

Andreas
