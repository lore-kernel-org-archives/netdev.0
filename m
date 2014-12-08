From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 17:31:11 -0500
Message-ID: <20141208223111.GA17949@redhat.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
 <20141208185635.GA25867@node.dhcp.inet.fi>
 <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
 <20141208192358.GB25867@node.dhcp.inet.fi>
 <20141208221401.GA4991@thunk.org>
 <CA+55aFz26Xvfs4iePpGgJotw+uwFCKduGqyM57adgfGepQYp_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Theodore Ts'o" <tytso@mit.edu>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFz26Xvfs4iePpGgJotw+uwFCKduGqyM57adgfGepQYp_w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 02:23:06PM -0800, Linus Torvalds wrote:
 > On Mon, Dec 8, 2014 at 2:14 PM, Theodore Ts'o <tytso@mit.edu> wrote:
 > >
 > > running trinity as root should be quite safe in a VM.  :-)
 > 
 > It's not so much the safety that I'd worry about, it's the "you can
 > legitimately just reboot it or cause kernel corruption as root". You
 > may not cause any problems outside of the VM, but any oopses inside
 > the VM might be due to trinity just doing bad things as root, rather
 > than kernel bugs..
 > 
 > Of course, it's probably hard to hit things like laoding random
 > modules etc, since even without signature requirements there are tons
 > of ELF sanity checks and other things. So it might be hard to actually
 > do those kinds of "corrupt kernel memory as root" things with trinity.

It also goes out of its way to avoid doing obviously stupid things,
like using /dev/mem as an fd, plus a whole bunch of similar sysfs/procfs
knobs.  There are still likely a whole bunch of similar things that
might have horrible effects too. It's been on my todo for a while to
revisit that particular case and blacklist a bunch of other things.

And then there's obviously "don't do this syscall, ever" or "with these
args" type things, which could use expanding.. It's a big effort tbh.
I'm amazed that Sasha, Kirill and everyone else running it as root in
vm's aren't buried alive in false-positives.

	Dave
 
