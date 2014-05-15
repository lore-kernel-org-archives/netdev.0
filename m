From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net V2] xen-netback: don't move event pointer
 in TX credit timeout callback
Date: Thu, 15 May 2014 14:59:06 +0100
Message-ID: <20140515135906.GH1117@zion.uk.xensource.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
 <5374C3EA.1080807@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Paul Durrant <paul.durrant@citrix.com>,
	<jajcus@jajcus.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63642 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbaEON7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 09:59:08 -0400
Content-Disposition: inline
In-Reply-To: <5374C3EA.1080807@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 02:40:58PM +0100, David Vrabel wrote:
> On 15/05/14 12:59, Wei Liu wrote:
> > ... otherwise the frontend will try to send TX event all the time, even
> > if no progress can be made. The pointer should only be advanced by the
> > routine that actually processes the ring (that is, xenvif_poll).
> 
> No it does not.  RING_FINAL_CHECK_FOR_REQUESTS() only advances the event
> index if the ring is empty.
> 
> This will also result in xenvif_up() failing to properly enable the event.
> 
> I think Jacek's bug may be that netback fails to call napi_complete()
> when credit is exceeded and there still outstanding requests on the
> from-guest ring and thus napi repeatedly polls.
> 

Correct. We should call napi_complete if this vif is rate limited.

Wei.
