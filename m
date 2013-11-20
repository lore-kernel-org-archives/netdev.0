From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 20 Nov 2013 09:46:08 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7438@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com> <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com> <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com> <1384787003.10077.34.camel@deadeye.wl.decadent.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B7430@saturn3.aculab.com> <20131119225822.GA9611@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Alan Stern" <stern@rowland.harvard.edu>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33155 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751962Ab3KTJrl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 04:47:41 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01760-05 for <netdev@vger.kernel.org>;
 Wed, 20 Nov 2013 09:47:38 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131119225822.GA9611@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sarah Sharp
...
> (Also, usb-storage aligns the block sizes to 512K, which explains why
> we've never had an issue with TD fragments with that driver.)

What is a 'block' in that context?
512K sounds more like the value that very long transfers get chopped
up into. With 4k pages that might be 128 fragments.

I'd have thought that the SG list would normally contain references
to a number of memory pages - so each would be 4k (on x86) aligned.
My suspicion is that the xhci controller will generate correct USB3
data provided the link TRB is on a 1k boundary - so such data won't
be a problem.

If a user program does a direct transfer from the block device
(and that is done by locking down the user pages) then the buffer
could have an arbitrary alignment.

	David
