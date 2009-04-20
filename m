From: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Tue, 21 Apr 2009 00:08:03 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0904202352520.2924@blonde.anvils>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera>
 <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain>
 <200904070035.00784.rjw@sisk.pl> <49E79E58.9000606@nortel.com>
 <alpine.LFD.2.00.0904161432000.4042@localhost.localdomain> <49ECE783.5050704@nortel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trenton Adams <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Chris Friesen <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49ECE783.5050704-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Apr 2009, Chris Friesen wrote:
> Linus Torvalds wrote:
> > On Thu, 16 Apr 2009, Chris Friesen wrote:
> > > I'm okay with that.  The problem causes some backwards compatibility
> > > problems
> > > with existing apps that get confused by the large "offset" number.  The
> > > fix is
> > > going to cause problems too, but in a different way.
> > >
> > > We'll work around it.
> > 
> > If you have actual apps that care, that's a different issue.

Yes, that's what I told Chris too.
But asked for more info, suspecting his app was already broken.

> > 
> > We do try to bend over backwards on ABI issues if it really is noticeable
> > for applications. Now, in this case, if you can just fix your app to not
> > care (because it really was badly written in the first place to even
> > notice), then that is the _much_ superior solution.
> 
> Yep, we can fix the app to ignore that field for anonymous mappings.
> 
> > Although I don't really even see what we can sanely do except for the 0
> > case. We could put the virtual address in there instead of zero (I forget
> > what old kernels used to do - whatever magic value the anonymous mappings
> > got, it wasn't really designed as an important value in its own right, it
> > was designed to trigger the "we can merge these vma's" logic.
> 
> For anonymous mappings, the older kernels put the starting address of the VMA
> (from the point of view of the app) as the offset.  Until the recent change,
> new kernels still did this for most VMAs, but the stack offset was a 64-bit
> value with no obvious relation to the VMA start address.

No, what they put there was something that in most cases matched the
starting address of the VMA; but try moving that VMA with mremap (and
an old /proc/<pid>/maps!) and you'll see that the "offset" remained
unchanged even when the starting address of the VMA was changed.

(The offset remaining constant so that rmap can locate the VMA's pages
and unmap them, despite their being mapped at different virtual
addresses in parent and child after a move in one of them.)

... so I think your app was indeed already broken, wasn't it?

It's also unclear why you'd want to use the offset field for the
starting address of the VMA, when /proc/<pid>/maps already shows
the starting address of the VMA.  I think you've more to tell us!

Hugh
