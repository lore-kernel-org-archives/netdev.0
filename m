From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: fix vif tx queue race in
 xenvif_rx_interrupt
Date: Thu, 9 Jan 2014 09:35:49 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0200D0D@AMSPEX01CL01.citrite.net>
References: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
 <20140108.151139.4522881609697040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"jieyue.majy@alibaba-inc.com" <jieyue.majy@alibaba-inc.com>,
	"yingbin.wangyb@alibaba-inc.com" <yingbin.wangyb@alibaba-inc.com>,
	"tienan.ftn@alibaba-inc.com" <tienan.ftn@alibaba-inc.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>,
	"majieyue@gmail.com" <majieyue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40131 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319AbaAIJhe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 04:37:34 -0500
In-Reply-To: <20140108.151139.4522881609697040.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: 08 January 2014 20:12
> To: majieyue@gmail.com
> Cc: netdev@vger.kernel.org; xen-devel@lists.xen.org; jieyue.majy@alibaba-
> inc.com; yingbin.wangyb@alibaba-inc.com; tienan.ftn@alibaba-inc.com; Wei
> Liu; Ian Campbell; David Vrabel
> Subject: Re: [PATCH net] xen-netback: fix vif tx queue race in
> xenvif_rx_interrupt
> 
> From: Ma JieYue <majieyue@gmail.com>
> Date: Thu,  9 Jan 2014 03:24:21 +0800
> 
> > -	if (xenvif_rx_schedulable(vif))
> > +	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
> 
> I do not see anything which prevents a netif_stop_queue() call from
> happening
> between these two tests in another thread of control.
> 
> This therefore looks like a bandaid and not a real fix.

My fix "xen-netback: improve guest-receive-side flow control" in net-next will make this change irrelevant as it completely removes all this somewhat fragile code.

  Paul

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
