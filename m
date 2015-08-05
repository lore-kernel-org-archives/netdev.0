From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH v2 4/8] xen: Use the correctly the Xen memory
 terminologies
Date: Wed, 5 Aug 2015 11:07:56 +0100
Message-ID: <alpine.DEB.2.02.1508051106420.11337@kaball.uk.xensource.com>
References: <1438711972-18752-1-git-send-email-julien.grall@citrix.com>
 <1438711972-18752-5-git-send-email-julien.grall@citrix.com>
 <55C147DD.7000600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, <x86@kernel.org>,
	=?UTF-8?Q?Roger_Pau_Monn=C3=A9?= <roger.pau@citrix.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Wei Liu <wei.liu2@citrix.com>, Juergen Gross <jgross@suse.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<linux-input@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-scs
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32221 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbbHEKJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 06:09:23 -0400
In-Reply-To: <55C147DD.7000600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Aug 2015, Boris Ostrovsky wrote:
> On 08/04/2015 02:12 PM, Julien Grall wrote:
> >     /*
> >    * We detect special mappings in one of two ways:
> > @@ -217,9 +232,13 @@ static inline unsigned long bfn_to_local_pfn(unsigned
> > long mfn)
> >     /* VIRT <-> MACHINE conversion */
> >   #define virt_to_machine(v)	(phys_to_machine(XPADDR(__pa(v))))
> > -#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
> >   #define virt_to_mfn(v)		(pfn_to_mfn(virt_to_pfn(v)))
> >   #define mfn_to_virt(m)		(__va(mfn_to_pfn(m) << PAGE_SHIFT))
> > +#define virt_to_pfn(v)          (PFN_DOWN(__pa(v)))
> 
> This looks like unnecessary change.
> 
> 
> > diff --git a/drivers/video/fbdev/xen-fbfront.c
> > b/drivers/video/fbdev/xen-fbfront.c
> > index 09dc447..25e3cce 100644
> > --- a/drivers/video/fbdev/xen-fbfront.c
> > +++ b/drivers/video/fbdev/xen-fbfront.c
> > @@ -539,7 +539,7 @@ static int xenfb_remove(struct xenbus_device *dev)
> >     static unsigned long vmalloc_to_mfn(void *address)
> >   {
> > -	return pfn_to_mfn(vmalloc_to_pfn(address));
> > +	return pfn_to_gfn(vmalloc_to_pfn(address));
> >   }
> 
> Are you sure? This will return vmalloc_to_pfn(address)).

I think that is OK: there is no behavioural change here.
