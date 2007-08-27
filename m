From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 1/2] [DM9000] Added support for big-endian hosts
Date: Mon, 27 Aug 2007 09:51:34 +0200
Message-ID: <200708270951.35269.laurentp@cse-semaphore.com>
References: <200708161015.35337.laurentp@cse-semaphore.com> <46CFB0BE.4030301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:50975 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751250AbXH0Hvi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 03:51:38 -0400
In-Reply-To: <46CFB0BE.4030301@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 25 August 2007 06:31, Jeff Garzik wrote:
> Laurent Pinchart wrote:
> > This patch splits the receive status in 8bit wide fields and conver=
t the
> > packet length from little endian to CPU byte order.
> >
> > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > ---
> >  drivers/net/dm9000.c |   13 +++++++------
> >  1 files changed, 7 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> > index c3de81b..a424810 100644
> > --- a/drivers/net/dm9000.c
> > +++ b/drivers/net/dm9000.c
> > @@ -894,7 +894,8 @@ dm9000_timer(unsigned long data)
> >  }
> >
> >  struct dm9000_rxhdr {
> > -	u16	RxStatus;
> > +	u8	RxPktReady;
> > +	u8	RxStatus;
> >  	u16	RxLen;
> >  } __attribute__((__packed__));
>
> why does this not need endian conversions as well?
>
> 	Jeff

The rx header is a 4-byte structure layed out as above (packet ready, s=
tatus=20
and length). The first two fields are 8-bit wide so don't need endian=20
conversion. The length field is a 16-bit big endian value which is conv=
erted=20
to CPU order in dm9000_rx().

Before this patch, the driver accessed the status and packet ready fiel=
ds as a=20
16-bit value, which was obviously endianess-dependant.

Best regards,

--=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=E9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75
