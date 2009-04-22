From: "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Wed, 22 Apr 2009 13:32:49 -0600
Message-ID: <49EF70E1.9030904@nortel.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera> <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain> <200904070035.00784.rjw@sisk.pl> <49E79E58.9000606@nortel.com> <alpine.LFD.2.00.0904161432000.4042@localhost.localdomain> <49ECE783.5050704@nortel.com> <Pine.LNX.4.64.0904202352520.2924@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0904202352520.2924-XZxpfvf5U/bbmfIwyoSfiQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hugh Dickins wrote:
> On Mon, 20 Apr 2009, Chris Friesen wrote:

>> For anonymous mappings, the older kernels put the starting address of the VMA
>> (from the point of view of the app) as the offset.  Until the recent change,
>> new kernels still did this for most VMAs, but the stack offset was a 64-bit
>> value with no obvious relation to the VMA start address.
> 
> No, what they put there was something that in most cases matched the
> starting address of the VMA; but try moving that VMA with mremap (and
> an old /proc/<pid>/maps!) and you'll see that the "offset" remained
> unchanged even when the starting address of the VMA was changed.
> 
> (The offset remaining constant so that rmap can locate the VMA's pages
> and unmap them, despite their being mapped at different virtual
> addresses in parent and child after a move in one of them.)
> 
> ... so I think your app was indeed already broken, wasn't it?
> 
> It's also unclear why you'd want to use the offset field for the
> starting address of the VMA, when /proc/<pid>/maps already shows
> the starting address of the VMA.  I think you've more to tell us!

Yeah, given the above the app was broken.  We just didn't run into any 
cases where the assumption caused any problems.

Also, it's not so much that we were relying on the offset value for 
anything, so much as we were parsing the file and had made some 
assumptions about valid offsets for anonymous memory.

Anyways, we'll fix it going forward to simply ignore the offset for 
anonymous memory.

Chris
