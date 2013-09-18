From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH net-next v4] Don't destroy the netdev until the vif is
 shut down
Date: Wed, 18 Sep 2013 17:25:17 +0100
Message-ID: <1379521517.11304.274.camel@hastur.hellion.org.uk>
References: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
	 <20130918103704.GA511@zion.uk.xensource.com>
	 <1379519895.11304.268.camel@hastur.hellion.org.uk>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD010D0DB@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53819 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793Ab3IRQZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 12:25:20 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD010D0DB@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-18 at 17:04 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Ian Campbell [mailto:ian.campbell@citrix.com]
> > Sent: 18 September 2013 16:58
> > To: Wei Liu
> > Cc: Paul Durrant; xen-devel@lists.xen.org; netdev@vger.kernel.org; David
> > Vrabel
> > Subject: Re: [PATCH net-next v4] Don't destroy the netdev until the vif is
> > shut down
> > 
> > On Wed, 2013-09-18 at 11:37 +0100, Wei Liu wrote:
> > > On Tue, Sep 17, 2013 at 05:46:08PM +0100, Paul Durrant wrote:
> > > > Without this patch, if a frontend cycles through states Closing
> > > > and Closed (which Windows frontends need to do) then the netdev
> > > > will be destroyed and requires re-invocation of hotplug scripts
> > > > to restore state before the frontend can move to Connected. Thus
> > > > when udev is not in use the backend gets stuck in InitWait.
> > > >
> > > > With this patch, the netdev is left alone whilst the backend is
> > > > still online and is only de-registered and freed just prior to
> > > > destroying the vif (which is also nicely symmetrical with the
> > > > netdev allocation and registration being done during probe) so
> > > > no re-invocation of hotplug scripts is required.
> > > >
> > > > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > > > Cc: David Vrabel <david.vrabel@citrix.com>
> > > > Cc: Wei Liu <wei.liu2@citrix.com>
> > > > Cc: Ian Campbell <ian.campbell@citrix.com>
> > >
> > > Acked-by: Wei Liu <wei.liu2@citrix.com>
> > 
> > yeah, looks good, thanks.
> > 
> > Paul, did you test this with non-Windows frontends too? and do things
> > like vif hot(un)plug still work?
> > 
> 
> Ian,
> 
> I tested with a debian (wheezy) PV guest but I didn't test unplug. I
> cycled a windows frontend several times (which is how I spotted the
> tx_irq thing), and shutdown and brought up both the debian and windows
> guests several times. I can test unplug too if you'd like.

I don't think it needs to be a blocker for accepting this patch but it
would be good to try it, it's the sort of area which historically gets
broken by this sort of change.

Ian.
> 
>   Paul
