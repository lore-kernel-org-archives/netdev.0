From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 17:19:33 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B746D@saturn3.aculab.com>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com> <20131202214205.GA26175@kroah.com> <52A166CB.4020508@pobox.com> <20131206170325.GA14254@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Mark Lord" <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131206170325.GA14254@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Sarah Sharp
> Sent: 06 December 2013 17:03
> To: Mark Lord
> Cc: Greg Kroah-Hartman; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; David Laight; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
> 
> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> > >>
> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into
> usb-linus (2013-11-27 09:49:03 -0800)
> > >>
> > >> are available in the git repository at:
> > >>
> > >>
> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> > >
> > > Pulled and pushed out, thanks.
> >
> > Did this commit make it into linux-3.12.3 ?
> >
> > I ask, because the NIC still locks up with that kernel,
> > and even with the patch I had been using from David Laight.
> >
> > Reverting the change that originally broke it still works though.
> > Could we please get this reverted until such time as a reworked
> > patch can be prepared for it?
> 
> Greg, can you please revert David's patch (commit 35773dac5f86 from your
> usb-linus branch)?
> 
> David said the patch fixed this lock up issue with his USB ethernet
> adapter, but Mark says it doesn't fix the issue.  The patch touches some
> hairy ring code in the xHCI driver, and I would rather not make any
> changes to that code unless we can prove there is an issue with that
> code.  We can always add the patch back later if it does turn out to fix
> an issue.

I thought Mark had said that my patch fixed things for him with the earlier
kernel.  It certainly makes a massive difference on my system.
And I ran with enough diagnostics to work out when the tx side stopped.
The last packet for which an ack was received was the one before the one
that straddled the ring end.

If you want to change the ax179 driver you need to stop it using
SG and segmentation offload.
The patch that mark is talking about isn't really the one that makes a difference.
I think it just forces the skb be linearised at that point. Which mostly
means that there won't be any fragments.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
