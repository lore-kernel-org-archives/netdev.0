From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 1/2]S2io: Strip the vlan tag if the vlan group is not NULL
Date: Sat, 24 Nov 2007 13:11:58 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702952493@nekter>
References: <474794BC.5030709@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:15812 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbXKXSMu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 13:12:50 -0500
Content-class: urn:content-classes:message
In-Reply-To: <474794BC.5030709@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I don't think this functionality is present in ethtool. I only see
#ifdef code in most of the drivers. What functionality do you mean?

We created this patch in response to the following thread with subject
line -
RE: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of keeping it

Since the Xframe hardware can dynamically turn Vlan stripping on and
off, we gave an option to the user to leave it in the default state
(strip the Vlan tag if a vlan group is present, else no stripping) or to
always turn OFF stripping (if say in promiscuous mode) or always turn it
ON (always strip vlan tags).

Ram
> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Friday, November 23, 2007 7:04 PM
> To: ram.vepa@neterion.com
> Cc: netdev@vger.kernel.org; support
> Subject: Re: [PATCH 2.6.24 1/2]S2io: Strip the vlan tag if the vlan
group
> is not NULL
> 
> Ramkrishna Vepa wrote:
> > - Updated the vlan tag stripping code as per Dave Johnson's patch
> >   <djohnson@sw.starentnetworks.com>
> >   Below is the driver behaviour for vlan_tag_strip loadable
paramter,
> > 	vlan_tag_strip - 0: Don't strip the vlan tag
> > 	vlan_tag_strip - 1: Always strip the vlan tag
> > 	vlan_tag_strip - 2 (default): strip the vlan tag if the
> > 	  vlan group is not NULL.
> >
> > Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> > ---
> > diff -Nurp 2.0.26.6/drivers/net/s2io.c 2.0.26.8P1/drivers/net/s2io.c
> > --- 2.0.26.6/drivers/net/s2io.c	2007-11-15 18:19:42.000000000
-0800
> > +++ 2.0.26.8P1/drivers/net/s2io.c	2007-11-15 18:15:00.000000000
-0800
> > @@ -46,10 +46,10 @@
> >   *     Possible values '1' for enable and '0' for disable. Default
is
> '1'
> >   * ufo: This parameter used to enable/disable UDP Fragmentation
> Offload(UFO)
> >   *      Possible values '1' for enable and '0' for disable. Default
is
> '0'
> > - * vlan_tag_strip: This can be used to enable or disable vlan
> stripping.
> > - *                 Possible values '1' for enable , '0' for
disable.
> > - *                 Default is '2' - which means disable in promisc
mode
> > - *                 and enable in non-promiscuous mode.
> > + * vlan_tag_strip: This can be used to enable or disable vlan tag
> stripping.
> > + *      Possible values '2' for driver default, '1' for enable and
> > + *      '0' for disable
> > + *      Default is '2' - VLAN tag stripping enabled if vlan group
> present
> >
>
************************************************************************
/
> 
> this should be controlled via ethtool and behave like other net
drivers
> 

