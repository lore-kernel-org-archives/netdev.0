From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 17:46:40 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B746F@saturn3.aculab.com>
References: <52A166CB.4020508@pobox.com><20131206170325.GA14254@xanatos><20131206172947.GA13222@kroah.com> <20131206.123218.1113571734746378151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <sarah.a.sharp@linux.intel.com>, <mlord@pobox.com>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47920 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751625Ab3LFRr0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:47:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23330-08 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 17:47:24 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131206.123218.1113571734746378151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> > From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date: Fri, 6 Dec 2013 09:29:47 -0800
> 
> > On Fri, Dec 06, 2013 at 09:03:25AM -0800, Sarah Sharp wrote:
> >> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> >> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> >> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> >> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> >> > >>
> >> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb
> into usb-linus (2013-11-27 09:49:03 -0800)
> >> > >>
> >> > >> are available in the git repository at:
> >> > >>
> >> > >>
> >> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> >> > >
> >> > > Pulled and pushed out, thanks.
> >> >
> >> > Did this commit make it into linux-3.12.3 ?
> >> >
> >> > I ask, because the NIC still locks up with that kernel,
> >> > and even with the patch I had been using from David Laight.
> >> >
> >> > Reverting the change that originally broke it still works though.
> >> > Could we please get this reverted until such time as a reworked
> >> > patch can be prepared for it?
> >>
> >> Greg, can you please revert David's patch (commit 35773dac5f86 from your
> >> usb-linus branch)?
> >
> > Now reverted.
> 
> Please NO!
> 
> Merge the XHCI change, the change you have reverted actually fixes
> things for some people and the XHCI change gets rid of the stated
> regression.

I know that some of the xhci ring code is rather complex [1].
But that particular patch should be completely safe as it just adds
some extra nop commands into the ring.

Possibly Mark is seeing some additional failure caused by something else.

Without my fix the xhci code carries on sending data to the usb hardware,
but no ethernet frames get transmitted.

[1] I've some thoughts on how to simplify some of the horridness, it also
ought to be possible to transmit from the USB Ge card with a similar
amount of cpu overhead as a reasonable (single queue) ethernet card.
At the moment the USB code has for horrid code paths.
But I'm not looking at that code at the moment because Sarah needs to
catch up with her patch queue.

	David
