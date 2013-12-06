From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 10:26:36 -0800
Message-ID: <20131206182636.GA30381@kroah.com>
References: <52A166CB.4020508@pobox.com>
 <20131206170325.GA14254@xanatos>
 <20131206172947.GA13222@kroah.com>
 <20131206.123218.1113571734746378151.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B746F@saturn3.aculab.com>
 <20131206181947.GB14254@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	David Laight <David.Laight@ACULAB.COM>, mlord@pobox.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56946 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616Ab3LFS0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:26:37 -0500
Content-Disposition: inline
In-Reply-To: <20131206181947.GB14254@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 10:19:47AM -0800, Sarah Sharp wrote:
> On Fri, Dec 06, 2013 at 05:46:40PM -0000, David Laight wrote:
> > > From: David Miller [mailto:davem@davemloft.net]
> > > > From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > > Date: Fri, 6 Dec 2013 09:29:47 -0800
> > > 
> > > > On Fri, Dec 06, 2013 at 09:03:25AM -0800, Sarah Sharp wrote:
> > > >> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> > > >> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> > > >> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> > > >> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> > > >> > >>
> > > >> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb
> > > into usb-linus (2013-11-27 09:49:03 -0800)
> > > >> > >>
> > > >> > >> are available in the git repository at:
> > > >> > >>
> > > >> > >>
> > > >> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> > > >> > >
> > > >> > > Pulled and pushed out, thanks.
> > > >> >
> > > >> > Did this commit make it into linux-3.12.3 ?
> > > >> >
> > > >> > I ask, because the NIC still locks up with that kernel,
> > > >> > and even with the patch I had been using from David Laight.
> > > >> >
> > > >> > Reverting the change that originally broke it still works though.
> > > >> > Could we please get this reverted until such time as a reworked
> > > >> > patch can be prepared for it?
> > > >>
> > > >> Greg, can you please revert David's patch (commit 35773dac5f86 from your
> > > >> usb-linus branch)?
> > > >
> > > > Now reverted.
> > > 
> > > Please NO!
> > > 
> > > Merge the XHCI change, the change you have reverted actually fixes
> > > things for some people and the XHCI change gets rid of the stated
> > > regression.
> > 
> > I thought Mark had said that my patch fixed things for him with the
> > earlier kernel.  It certainly makes a massive difference on my system.
> > And I ran with enough diagnostics to work out when the tx side
> > stopped.  The last packet for which an ack was received was the one
> > before the one that straddled the ring end.
> >
> > If you want to change the ax179 driver you need to stop it using
> > SG and segmentation offload.
> > The patch that mark is talking about isn't really the one that makes a
> > difference.
> > I think it just forces the skb be linearised at that point. Which mostly
> > means that there won't be any fragments.
> 
> Ok, so David verifies the xHCI driver does have an issue, and the patch
> does fix the issue as stated.  Fine, let's merge that patch and see if
> it helps.  Greg, can you fix this?  Sorry for the churn.

Yes, I've pushed it to Linus now, not including the revert.

greg k-h
