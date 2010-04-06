From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 6 Apr 2010 14:12:28 -0600
Message-ID: <2913b19f-188e-475e-8f16-d3ad94614a08@VA3EHSMHS030.ehs.local>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local> <1270502993.9013.36.camel@edumazet-laptop> <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local> <1270573233.2081.47.camel@edumazet-laptop> <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local> <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com> <1270584223.3949.57.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>, <michal.simek@petalogix.com>,
	"John Tyner" <jtyner@cs.ucr.edu>
To: <steve@digidescorp.com>, <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.15]:49065
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752927Ab0DFUMm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 16:12:42 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <1270584223.3949.57.camel@iscandar.digidescorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Steven J. Magnani [mailto:steve@digidescorp.com]
> Sent: Tuesday, April 06, 2010 2:04 PM
> To: grant.likely@secretlab.ca
> Cc: John Linn; Eric Dumazet; netdev@vger.kernel.org;
linuxppc-dev@ozlabs.org;
> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com;
michal.simek@petalogix.com; John Tyner
> Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
> 
> On Tue, 2010-04-06 at 12:53 -0600, Grant Likely wrote:
> 
> > Hold on.... BUFFER_ALIGN is being used to align the DMA buffer on a
> > cache line boundary.  I don't think netdev_alloc_skb() makes any
> > guarantees about how the start of the IP header lines up against
cache
> > line boundaries.  The amount of padding needed is not known until an
> > skbuff is obtained from netdev_alloc_skb(), and
> > netdev_alloc_skb_ip_align() can only handle a fixed size padding,
> >
> > It doesn't look like netdev_alloc_skb_ip_align() is the right thing
in
> > this regard.
> 
> __netdev_alloc_skb reserves NET_SKB_PAD bytes which gets us cacheline
> alignment on Microblaze. From include/linux/skbuff.h:
> 

Good find. I'll give it a test on MicroBlaze and PowerPC.

> /*
>  * The networking layer reserves some headroom in skb data (via
>  * dev_alloc_skb). This is used to avoid having to reallocate skb data
> when
>  * the header has to grow. In the default case, if the header has to
> grow
>  * 32 bytes or less we avoid the reallocation.
>  *
>  * Unfortunately this headroom changes the DMA alignment of the
> resulting
>  * network packet. As for NET_IP_ALIGN, this unaligned DMA is
expensive
>  * on some architectures. An architecture can override this value,
>  * perhaps setting it to a cacheline in size (since that will maintain
>  * cacheline alignment of the DMA). It must be a power of 2.
>  *
>  * Various parts of the networking layer expect at least 32 bytes of
>  * headroom, you should not reduce this.
>  */
> #ifndef NET_SKB_PAD
> #define NET_SKB_PAD     32
> #endif
> 
> If this doesn't work for some of the PPC variants with larger cache
> lines, maybe one of the PPC header files needs to define NET_SKB_PAD?

Looks like it is defined in system.h in powerpc so that it works.

> And if we want to guard against possible future changes to the default
> NET_SKB_PAD breaking Microblaze operation, maybe one of its headers
> should define NET_SKB_PAD as well?

Good idea, we can add that to system.h for MicroBlaze also.

Thanks,
John

> 
>
------------------------------------------------------------------------
>  Steven J. Magnani               "I claim this network for MARS!
>  www.digidescorp.com              Earthling, return my space
modulator!"
> 
>  #include <standard.disclaimer>
> 
> 
> 


This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


