From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 20 Nov 2013 09:36:11 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
References: <20131119225822.GA9611@xanatos> <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Alan Stern" <stern@rowland.harvard.edu>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32945 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752142Ab3KTJib convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 04:38:31 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31558-04 for <netdev@vger.kernel.org>;
 Wed, 20 Nov 2013 09:38:28 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Alan Stern [mailto:stern@rowland.harvard.edu]
> On Tue, 19 Nov 2013, Sarah Sharp wrote:
> 
> > The xHCI driver can limit the number of sg-list entries through
> > hcd->self.sg_tablesize.  It's currently set to ~0, which is "however
> > many entries you want.  You could set that to the number of TRBs in a
> > segment (minus one for the link TRB).
> >
> > The usb-storage and uas drivers currently use sg_tablesize.  Could the
> > network stack be taught to use sg_tablesize as well?
> 
> The sg_tablesize you're talking about is a field in struct usb_bus
> (there's a similar field in struct scsi_host_template).  It's not
> relevant to the network stack, since network interfaces aren't USB host
> controllers (or SCSI hosts).

Ben said the largest number of fragments from the current network
stack will be 17, and that none of them will cross 32k boundaries.
So the network stack won't send down long SG lists.

	David
