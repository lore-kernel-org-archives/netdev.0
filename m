From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Thu, 21 Nov 2013 09:53:50 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B743E@saturn3.aculab.com>
References: <20131119225822.GA9611@xanatos> <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com> <20131120160605.GB9611@xanatos> <AE90C24D6B3A694183C094C60CF0A2F6026B743D@saturn3.aculab.com> <A2CA0424C0A6F04399FB9E1CD98E030458E28EB7@US01WEMBX2.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Alan Stern" <stern@rowland.harvard.edu>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Paul Zimmerman" <Paul.Zimmerman@synopsys.com>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51719 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752629Ab3KUJ4X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 04:56:23 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17972-02 for <netdev@vger.kernel.org>;
 Thu, 21 Nov 2013 09:56:21 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <A2CA0424C0A6F04399FB9E1CD98E030458E28EB7@US01WEMBX2.internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > My suspicion is that long SG lists are unusual - otherwise the
> > ring expansion code would have been needed much earlier.
> >
> > Can anyone remember whether that was needed because of long SG lists
> > or because of large numbers of outstanding requests?
> >
> > I've seen it for network cards - but only because usbnet sends
> > down far too many tx buffers.
> 
> usb-storage limits the maximum transfer size to 120K. That is a max of
> 31 page-size segments if my math is right. That's probably why mass-storage
> never saw a problem.

I found some references to mass storage running out of ring space.

My best guess as to why mass storage has never had a problem with
the alignment at link TRBs is that the effect of getting it wrong
is to split the transfer. Since almost all the transfers are of page
aligned data that will only happen on a 1k boundary - where it is
invisible to the target.

For USB2 targets the link TRB only has to be 512 byte aligned.
The constraint that mass storage applied for the usb2 controllers
is enough to satisfy it.

	David
