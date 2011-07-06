From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38862] New: No support for DGE-530T Rev C1
Date: Wed, 6 Jul 2011 14:54:07 -0700
Message-ID: <20110706145407.7e06eece.akpm@linux-foundation.org>
References: <bug-38862-10286@https.bugzilla.kernel.org/>
	<20110706143709.0f5ab7d6.akpm@linux-foundation.org>
	<4E14D83C.1090506@ruggedcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: James Henderson <JamesHenderson@ruggedcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40360 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751519Ab1GFVyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 17:54:11 -0400
In-Reply-To: <4E14D83C.1090506@ruggedcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jul 2011 17:48:44 -0400
James Henderson <JamesHenderson@ruggedcom.com> wrote:

> > Did you test simply adding that device to the driver?
> >
> > --- a/drivers/net/skge.c~a
> > +++ a/drivers/net/skge.c
> > @@ -89,6 +89,7 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
> > +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	/* DGE-530T Rev C1 */
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
> >  	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
> > _
> >
> >   
> No I haven't tested that change - I don't have a kernel development 
> environment setup and unfortunately I don't have any more work time to 
> budget to the issue beyond reporting it.
> 
> Also, I meant to say that Rev B2 has PCI id 1186:4B01 (although you seem 
> to have figured that out).

OK, I suppose we can add that info thusly:

--- a/drivers/net/skge.c~drivers-net-skgec-support-dlink-dge-530t-rev-c1
+++ a/drivers/net/skge.c
@@ -88,7 +88,8 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T Rev B2 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	/* DGE-530T Rev C1 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
 	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
_

although that might be misleading if, say, 0x4b01 describes other
revisions.

But there isn't much we can do with this until someone can test the
change.

