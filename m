From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] xen-netback: stop vif thread spinning if
 frontend is unresponsive
Date: Wed, 8 Jan 2014 09:49:53 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01E6DF8@AMSPEX01CL01.citrite.net>
References: <1389111929-37231-1-git-send-email-paul.durrant@citrix.com>
 <20140107.162956.1062166230525232035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14219 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbaAHJtz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:49:55 -0500
In-Reply-To: <20140107.162956.1062166230525232035.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: 07 January 2014 21:30
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xen.org; Wei Liu; Ian Campbell;
> David Vrabel
> Subject: Re: [PATCH net-next] xen-netback: stop vif thread spinning if
> frontend is unresponsive
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Tue, 7 Jan 2014 16:25:29 +0000
> 
> > @@ -477,6 +477,7 @@ static void xenvif_rx_action(struct xenvif *vif)
> >  	unsigned long offset;
> >  	struct skb_cb_overlay *sco;
> >  	int need_to_notify = 0;
> > +	int ring_full = 0;
> 
> Please use bool, false, and true.
> 
> >
> > -	if (!npo.copy_prod)
> > +	if (!npo.copy_prod) {
> > +		if (ring_full)
> > +			vif->rx_queue_stopped = true;
> >  		goto done;
> > +	}
> > +
> > +	vif->rx_queue_stopped = false;
> 
> And then you can code this as:
> 
> 	vif->rx_queue_stopped = (!npo.copy_prod && ring_full);
> 	if (!npo.copy_prod)
> 		goto done;

Sure. I was just following style (of need_to_notify). If you prefer bool then I'll use that and also convert need_to_notify.

  Paul

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
