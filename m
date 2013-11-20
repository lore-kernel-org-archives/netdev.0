From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 20 Nov 2013 17:16:12 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B743D@saturn3.aculab.com>
References: <20131119225822.GA9611@xanatos> <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com> <20131120160605.GB9611@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Alan Stern" <stern@rowland.harvard.edu>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41000 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754540Ab3KTRT0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 12:19:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24095-09 for <netdev@vger.kernel.org>;
 Wed, 20 Nov 2013 17:19:23 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131120160605.GB9611@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok, so the networking layer should be fine.  However, with the current
> patch, if the mass storage driver sends down a scatter-gather list
> that's bigger than a ring segment, or needs to be split up so it doesn't
> cross 64K boundaries, then the URB submission will fail.  We don't want
> that to happen.

My suspicion is that long SG lists are unusual - otherwise the
ring expansion code would have been needed much earlier.

Can anyone remember whether that was needed because of long SG lists
or because of large numbers of outstanding requests?

I've seen it for network cards - but only because usbnet sends
down far too many tx buffers.

	David
