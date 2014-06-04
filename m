From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v10 1/7] xen-netback: Move grant_copy_op array
 back into struct xenvif.
Date: Wed, 4 Jun 2014 16:03:03 +0100
Message-ID: <20140604150303.GK6043@zion.uk.xensource.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com>
 <1401874247-3202-2-git-send-email-wei.liu2@citrix.com>
 <538F3152.80501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>,
	<paul.durrant@citrix.com>, <a.j.bennieston@gmail.com>,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:49017 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbaFDPDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 11:03:04 -0400
Content-Disposition: inline
In-Reply-To: <538F3152.80501@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2014 at 06:46:42PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 06/04/2014 01:30 PM, Wei Liu wrote:
> 
> >From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> >This array was allocated separately in commit ac3d5ac2 ("xen-netback:
> >fix guest-receive-side array sizes") due to it being very large, and a
> >struct xenvif is allocated as the netdev_priv part of a struct
> >net_device, i.e. via kmalloc() but falling back to vmalloc() if the
> >initial alloc. fails.
> 
> >In preparation for the multi-queue patches, where this array becomes
> >part of struct xenvif_queue and is always allocated through vzalloc(),
> >move this back into the struct xenvif.
> 
>    Won't this cause an allocation failure and so break bisection at this patch?
> 

As stated in the commit message, this array is now allocated with
vzalloc, which is no different from what it was done before (with
vmalloc in ac3d5ac2).

Wei.

> >Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> >Acked-by: Wei Liu <wei.liu2@citrix.com>
> 
> WBR, Sergei
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
