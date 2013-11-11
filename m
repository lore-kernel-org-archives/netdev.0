From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Mon, 11 Nov 2013 17:12:29 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73FE@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73F4@saturn3.aculab.com> <Pine.LNX.4.44L0.1311081303460.1162-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311081303460.1162-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Alan Stern [mailto:stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org]
> On Fri, 8 Nov 2013, David Laight wrote:
> 
...
> GET_MAX_PACKET always returns MaxPacketSize, and for USB-3 bulk
> endpoints, MaxPacketSize is always 1024.  MaxBurstSize can be anything
> from 1 to 16.

I've just read something that explained about bursts.

> > > According to my version of the spec (Rev 1.0, dated 5/21/2010), if a TD
> > > is larger than the MBP and its length isn't a multiple of the MBP, then
> > > the last MBP boundary in the TD must also be a TRB boundary.  This
> > > follows from two statements in section 4.11.7.1:
> > >
> > > 	If the TD Transfer Size is an even multiple of the MBP then all
> > > 	TD Fragments shall define exact multiples of MBP data bytes.
> > > 	If not, then only the last TD Fragment shall define less than
> > > 	MBP data (or the Residue) bytes.
> >
> > No, that doesn't stop there being only 1 TD fragment.
> > (I think it means exact multiple of the MBP.)
> 
> Suppose, for example, the MBP is 1024.  If you have a TD with length
> 1500, and if it had only one fragment, the last (and only) fragment's
> length would not less than the MBP and it would not be an exact
> multiple of the MBP.

That doesn't matter - eg example 2 in figure 25
 
> I agree that the text is not as clear as it should be.

Reading it all again makes me think that a LINK trb is only
allowed on the burst boundary (which might be 16k bytes).
The only real way to implement that is to ensure that TD never
contain LINK TRB.

There are other things that can be done at a TD fragment boundary
(or only once per TD fragment) - but the code doesn't attempt any
of them.

The restriction might be there to simplify the hardware to
retransmit as TRB burst.

My USB3 ethernet card (ax88179_178a driver) is running a lot more
reliably with these changes.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
