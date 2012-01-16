From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Mon, 16 Jan 2012 09:33:14 +0000
Message-ID: <1326706394.5285.5.camel@liuw-desktop>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
	 <4F107625.7090601@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:21109 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab2APJeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 04:34:00 -0500
In-Reply-To: <4F107625.7090601@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-13 at 18:21 +0000, David Vrabel wrote:
> On 13/01/12 16:59, Wei Liu wrote:
> > This patch implements 1:1 model netback. We utilizes NAPI and kthread
> > to do the weight-lifting job:
> > 
> >   - NAPI is used for guest side TX (host side RX)
> >   - kthread is used for guest side RX (host side TX)
> > 
> > This model provides better scheduling fairness among vifs. It also
> > lays the foundation for future work.
> > 
> > The major defect for the current implementation is that in the NAPI
> > poll handler we don't actually disable interrupt. Xen stuff is
> > different from real hardware, it requires some other tuning of ring
> > macros.
> 
> RING_FINAL_CHECK_FOR_REQUESTS() looks it does the correct thing to me.
> 
> David

I need to stop the other end from generating events, so
RING_FINAL_CHECK_FOR_REQUESTS is not the right answer I think.


Wei.
