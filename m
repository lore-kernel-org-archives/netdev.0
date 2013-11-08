From: Alan Stern <stern@rowland.harvard.edu>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Fri, 8 Nov 2013 13:12:42 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311081303460.1162-100000@iolanthe.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73F4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:57312 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757479Ab3KHSMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:12:44 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73F4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Nov 2013, David Laight wrote:

> > The whole idea of TD fragments is exceedingly cloudy.  The definition
> > doesn't make sense, and the spec doesn't say what the actual hardware
> > restrictions are, i.e., what is the underlying reality that the TD
> > fragment concept wants to express.
> 
> I think that a TD fragment boundary exists whenever a TRB/dma boundary
> lines up with the packet boundary.

The spec doesn't say that.

> > Even if you do your best to ignore the whole idea, there still appear
> > to be certain restrictions you need to obey.  In addition to the
> > question of where Link TRBs are allowed, you also have to worry about
> > TDs whose size isn't a multiple of the Max Burst Payload (MBP) size =
> > MaxBurstSize * MaxPacketSize.
> 
> I'm not certain what MaxBurstSize and MaxPacketSize are, but the important
> number is the MBP. I'm fairly sure that is the value returned by
> GET_MAX_PACKET() - 1024 for USB3 bulk endpoints.

GET_MAX_PACKET always returns MaxPacketSize, and for USB-3 bulk
endpoints, MaxPacketSize is always 1024.  MaxBurstSize can be anything
from 1 to 16.

> > According to my version of the spec (Rev 1.0, dated 5/21/2010), if a TD
> > is larger than the MBP and its length isn't a multiple of the MBP, then
> > the last MBP boundary in the TD must also be a TRB boundary.  This
> > follows from two statements in section 4.11.7.1:
> > 
> > 	If the TD Transfer Size is an even multiple of the MBP then all
> > 	TD Fragments shall define exact multiples of MBP data bytes.
> > 	If not, then only the last TD Fragment shall define less than
> > 	MBP data (or the Residue) bytes.
> 
> No, that doesn't stop there being only 1 TD fragment.
> (I think it means exact multiple of the MBP.)

Suppose, for example, the MBP is 1024.  If you have a TD with length
1500, and if it had only one fragment, the last (and only) fragment's
length would not less than the MBP and it would not be an exact 
multiple of the MBP.

I agree that the text is not as clear as it should be.

Alan Stern
