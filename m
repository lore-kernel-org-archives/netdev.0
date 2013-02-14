From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netback: cancel the credit timer
 when taking the vif down
Date: Thu, 14 Feb 2013 14:21:43 +0000
Message-ID: <1360851703.16636.146.camel@zion.uk.xensource.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
	 <1360847938-11185-3-git-send-email-david.vrabel@citrix.com>
	 <1360849999.16636.135.camel@zion.uk.xensource.com>
	 <511CFF8A02000078000BE4B2@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	KonradRzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:48845 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab3BNOWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 09:22:06 -0500
In-Reply-To: <511CFF8A02000078000BE4B2@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 14:15 +0000, Jan Beulich wrote:
> >>> On 14.02.13 at 14:53, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Thu, 2013-02-14 at 13:18 +0000, David Vrabel wrote:
> >> From: David Vrabel <david.vrabel@citrix.com>
> >> 
> >> If the credit timer is left armed after calling
> >> xen_netbk_remove_xenvif(), then it may fire and attempt to schedule
> >> the vif which will then oops as vif->netbk == NULL.
> >> 
> >> This may happen both in the fatal error path and during normal
> >> disconnection from the front end.
> >> 
> >> The sequencing during shutdown is critical to ensure that: a)
> >> vif->netbk doesn't become unexpectedly NULL; and b) the net device/vif
> >> is not freed.
> >> 
> >> 1. Mark as unschedulable (netif_carrier_off()).
> >> 2. Synchronously cancel the timer.
> >> 3. Remove the vif from the schedule list.
> >> 4. Remove it from it netback thread group.
> >> 5. Wait for vif->refcnt to become 0.
> >> 
> >> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> > 
> > You would need to reinitialize the timer in xenvif_up, given that user
> > might `ifconfig vifX.X down; ifconfig vifX.X up`.
> 
> Which gets us to another aspect of the original fix that I don't
> think was considered: Is there anything preventing the interface
> to be brought back up after fatal_tx_err() shut it down?
> 

I don't think so. Code could / should not prevent host admin from doing
anything he wants - even it is re-enabling a malicious vif. ;-)


Wei.

> Jan
> 
