From: Paul Zimmerman <Paul.Zimmerman@synopsys.com>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 21:11:37 +0000
Message-ID: <A2CA0424C0A6F04399FB9E1CD98E030458E28EB7@US01WEMBX2.internal.synopsys.com>
References: <20131119225822.GA9611@xanatos>
 <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
 <20131120160605.GB9611@xanatos>
 <AE90C24D6B3A694183C094C60CF0A2F6026B743D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kiruna.synopsys.com ([198.182.44.80]:65168 "EHLO
	kiruna.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab3KTVLk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 16:11:40 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B743D@saturn3.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-owner@vger.kernel.org] On Behalf Of David Laight
> Sent: Wednesday, November 20, 2013 9:16 AM
> 
> > Ok, so the networking layer should be fine.  However, with the current
> > patch, if the mass storage driver sends down a scatter-gather list
> > that's bigger than a ring segment, or needs to be split up so it doesn't
> > cross 64K boundaries, then the URB submission will fail.  We don't want
> > that to happen.
> 
> My suspicion is that long SG lists are unusual - otherwise the
> ring expansion code would have been needed much earlier.
> 
> Can anyone remember whether that was needed because of long SG lists
> or because of large numbers of outstanding requests?
> 
> I've seen it for network cards - but only because usbnet sends
> down far too many tx buffers.

usb-storage limits the maximum transfer size to 120K. That is a max of
31 page-size segments if my math is right. That's probably why mass-storage
never saw a problem.

-- 
Paul
