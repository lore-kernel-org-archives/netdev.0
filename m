From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 16:43:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0909221139570.12001@makko.or.mcafeemobile.com>
References: <20090912094110.GB24709@ioremap.net> <20090921231227.GJ14700@shareable.org> <alpine.DEB.2.00.0909211816020.1116@makko.or.mcafeemobile.com> <200909221731.34717.agruen@suse.de> <1253635918.2747.5.camel@dhcp231-106.rdu.redhat.com>
 <20090922162707.GA11608@shareable.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Paris <eparis@redhat.com>,
	Andreas Gruenbacher <agruen@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090922162707.GA11608@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Sep 2009, Jamie Lokier wrote:

> Eric Paris wrote:
> > That's not the fatal flaw.  The fatal flaw is that I am not going to
> > write 90% of a rootkit and make it easy to use.
> 
> I hate to point out the obvious, but fanotify's ability to intercept
> every file access and rewrite the file before the access proceeds is
> also 90% of a rootkit...

Obvious, but worth noticing.
Indeed, the syscall table has been RO to make it harder for RKs to 
exploit it, not to make it impossible. RO syscall table makes perfect 
sense.
But, once you are root, with very few lines of code, you can find, 
prot-fix the page, and patch the table.



> But fortunately both fanotify and syscall rewriting require root in
> the first place.                          ^^^^^^^^^

Again, maybe I wasn't clear about how this would work, but the syscall 
table would continue to remain RO ;)
And as I said before, if we want to bring the cost of the interception for 
non-users pretty close to zero (a few NOPs to run onto), we could even 
adopt an alternative-like patching triggered by a kernel boot option.



- Davide


