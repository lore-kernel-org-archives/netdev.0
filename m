From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: e100 skb allocation
Date: Wed, 24 Jun 2009 12:54:21 -0400
Message-ID: <20090624165421.GB18486@hmsreliant.think-freely.org>
References: <b9e8fcbd0906240149g2f2e18f2vcd7dce234c949564@mail.gmail.com> <20090624104750.GA18486@hmsreliant.think-freely.org> <b9e8fcbd0906240928h6c5db9a6va48e42799376149e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nicholas Van Orton <turanammo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44723 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760596AbZFXQy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 12:54:27 -0400
Content-Disposition: inline
In-Reply-To: <b9e8fcbd0906240928h6c5db9a6va48e42799376149e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 09:58:38PM +0530, Nicholas Van Orton wrote:
> On Wed, Jun 24, 2009 at 4:17 PM, Neil Horman<nhorman@tuxdriver.com> w=
rote:
> > On Wed, Jun 24, 2009 at 02:19:48PM +0530, Nicholas Van Orton wrote:
> >> Hello,
> >>
> >> =A0 =A0 =A0 For the Intel 8256 Ethernet Controller (e100.c), I not=
ice that at the
> >> time of skb allocation using netdev_alloc_skb() and just before
> >> calling skb_reserve(), rx->skb->head and rx->skb->tail do not poin=
t to
> >> the same location. In fact they are already 16bytes apart. After
> >> calling =A0skb_reserve(), which would add a 2 byte padding, head a=
nd
> >> tail would be 18 bytes apart. Is this behaviour correct? Shouldn't=
 the
> >> ethernet header be 14+2 bytes after padding? Why aren't head and t=
ail
> >> at the same location at the beginning?
> >>
> > Yes, its fine (although IIRC it should be 32, rather than 16 bytes)=
=2E
> > netdev_alloc_skb, in its implementation, allocates an skb that is N=
ET_SKB_PAD
> > bytes larger than the caller requested, then it calls skb_reserve i=
nternally to
> > add NET_SKB_PAD bytes of data to the skb's buffer.
> >
>=20
> Thanks a bunch for steering me in the right direction. Things are muc=
h
> clearer now.
>=20
No problem :)
Neil

