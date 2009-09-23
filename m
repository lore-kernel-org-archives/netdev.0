From: Tvrtko Ursulin <tvrtko.ursulin@sophos.com>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 09:39:33 +0100
Message-ID: <200909230939.34003.tvrtko.ursulin@sophos.com>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"hch@infradead.org" <hch@infradead.org>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmx1.sophos.com ([213.31.172.16]:36358 "EHLO pmx1.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527AbZIWIsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 04:48:42 -0400
In-Reply-To: <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 September 2009 17:04:44 Davide Libenzi wrote:
> On Tue, 22 Sep 2009, Andreas Gruenbacher wrote:
> > The fatal flaw of syscall interception is race conditions: you look up a
> > pathname in your interception layer; then when you call into the proper
> > syscall, the kernel again looks up the same pathname. There is no way to
> > guarantee that you end up at the same object in both lookups. The
> > security and fsnotify hooks are placed in the appropriate spots to avoid
> > exactly that.
>
> Fatal? You mean, for this corner case that the anti-malware industry lived
> with for so much time (in Linux and Windows), you're prepared in pushing
> all the logic that is currently implemented into their modules, into the
> kernel?

Lived with it because there was no other option. We used LSM while it was 
available for modules but then it was taken away. 

And not all vendors even use syscall interception, not even across platforms, 
of which you sound so sure about. You can't even scan something which is not 
in your namespace if you are at the syscall level. And you can't catch things 
like kernel nfsd. No, syscall interception is not really appropriate at all.

Tvrtko
