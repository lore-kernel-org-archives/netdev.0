From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next 2/2] xen-netback: handle frontends that fail to
 transition through Closing
Date: Fri, 20 Sep 2013 13:38:33 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD010EFD7@AMSPEX01CL01.citrite.net>
References: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com>
 <1379681791-21842-3-git-send-email-paul.durrant@citrix.com>
 <20130920133448.GC457@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64708 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590Ab3ITNii convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 09:38:38 -0400
In-Reply-To: <20130920133448.GC457@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 20 September 2013 14:35
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xen.org; David Vrabel; Wei Liu;
> Ian Campbell
> Subject: Re: [PATCH net-next 2/2] xen-netback: handle frontends that fail to
> transition through Closing
> 
> On Fri, Sep 20, 2013 at 01:56:31PM +0100, Paul Durrant wrote:
> > Some old Windows frontends fail to transition through the xenbus Closing
> > state and move directly from Connected to Closed. Handle this case
> properly.
> >
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Cc: David Vrabel <david.vrabel@citrix.com>
> > Cc: Wei Liu <wei.liu2@citrix.com>
> > Cc: Ian Campbell <ian.campbell@citrix.com>
> > ---
> >  drivers/net/xen-netback/xenbus.c |    2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> > index a53782e..bcaa25b 100644
> > --- a/drivers/net/xen-netback/xenbus.c
> > +++ b/drivers/net/xen-netback/xenbus.c
> > @@ -265,6 +265,8 @@ static void frontend_changed(struct xenbus_device
> *dev,
> >  		break;
> >
> >  	case XenbusStateClosed:
> > +		if (dev->state == XenbusStateConnected)
> > +			disconnect_backend(dev);
> 
> Could you please add a comment above this change stating that this is a
> workaround for some old frontend that we cannot fix / upgrade.
> 
> We would still like to later frontend goes through the normal connected
> -> closing -> closed path.
> 

Sure. I'll re-post the series with that change.

  Paul
