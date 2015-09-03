From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH v2 net-next] xen-netback: add support for
 multicast control
Date: Thu, 3 Sep 2015 09:00:44 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD02F5B0516@AMSPEX01CL01.citrite.net>
References: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
 <55E82768020000780009F32F@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:60336 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbbICJAq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 05:00:46 -0400
In-Reply-To: <55E82768020000780009F32F@prv-mh.provo.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 03 September 2015 09:57
> To: Paul Durrant
> Cc: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org
> Subject: Re: [Xen-devel] [PATCH v2 net-next] xen-netback: add support for
> multicast control
> 
> >>> On 02.09.15 at 18:58, <paul.durrant@citrix.com> wrote:
> > @@ -1215,6 +1289,31 @@ static void xenvif_tx_build_gops(struct
> xenvif_queue *queue,
> >  				break;
> >  		}
> >
> > +		if (extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1].type) {
> > +			struct xen_netif_extra_info *extra;
> > +
> > +			extra =
> &extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1];
> > +			ret = xenvif_mcast_add(queue->vif, extra-
> >u.mcast.addr);
> 
> What's the reason this call isn't gated on vif->multicast_control?
> 

No particular reason. I guess it eats a small amount of memory for no gain but a well behaved frontend wouldn't send such a request and a malicious one can only send 64 of them before netback starts to reject them.

  Paul

> Jan
