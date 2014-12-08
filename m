From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 14:15:51 -0500
Message-ID: <20141208191551.GA7525@redhat.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208185635.GA25867@node.dhcp.inet.fi>
 <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 11:01:41AM -0800, Linus Torvalds wrote:
 > On Mon, Dec 8, 2014 at 10:56 AM, Kirill A. Shutemov
 > <kirill@shutemov.name> wrote:
 > >
 > > trinity triggers it for me in few minutes. I will try find out more once
 > > get some time.
 > 
 > You run trinity as *root*?
 > 
 > You're a brave man. Stupid, but brave ;)
 > 
 > I guess you're running it in a VM, but still.. Doing random system
 > calls as root sounds like a bad bad idea.

I've flip-flopped on this a few times.  I used to be solidly in the same
position as your statement, but after seeing the things the secure-boot
crowd want to lock down, there are a ton of places in the kernel that
would need additional root-proofing to avoid scribbling over kernel
memory.

In short though, yeah, expect fireworks right now, especially on bare-metal.

At the same time, just to increase coverage testing of a lot of
root-required functionality (like various network sockets that can't be
opened as a regular user) I added a --drop-privs mode to trinity a while
ago, so after the socket creation, it can't do anything _too_ crazy.

	Dave
