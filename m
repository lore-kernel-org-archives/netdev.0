From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/2] xen-netback: cancel the credit timer
 when taking the vif down
Date: Thu, 14 Feb 2013 14:10:17 +0000
Message-ID: <1360851017.16636.141.camel@zion.uk.xensource.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
	 <1360847938-11185-3-git-send-email-david.vrabel@citrix.com>
	 <1360849999.16636.135.camel@zion.uk.xensource.com>
	 <511CED08.9080902@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Beulich <jbeulich@suse.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:31695 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757635Ab3BNOKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 09:10:18 -0500
In-Reply-To: <511CED08.9080902@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 13:56 +0000, David Vrabel wrote:
> On 14/02/13 13:53, Wei Liu wrote:
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
> No.  Deleted timers do not need to be reinitialized.  The timer will be

What I really meant was to "rearm"...

> armed as usual with mod_timer() when credit is next exhausted.
> 

Ah, ok.


Wei.
