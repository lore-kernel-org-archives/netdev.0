From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: handle frontends that fail to
 transition through Closing
Date: Fri, 20 Sep 2013 14:48:35 +0100
Message-ID: <20130920134835.GD457@zion.uk.xensource.com>
References: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com>
 <1379681791-21842-3-git-send-email-paul.durrant@citrix.com>
 <20130920133448.GC457@zion.uk.xensource.com>
 <523C4FE6.30309@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:3962 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754965Ab3ITNsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 09:48:36 -0400
Content-Disposition: inline
In-Reply-To: <523C4FE6.30309@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 20, 2013 at 02:38:46PM +0100, David Vrabel wrote:
> On 20/09/13 14:34, Wei Liu wrote:
> > On Fri, Sep 20, 2013 at 01:56:31PM +0100, Paul Durrant wrote:
> >> Some old Windows frontends fail to transition through the xenbus Closing
> >> state and move directly from Connected to Closed. Handle this case properly.
> >>
> >> --- a/drivers/net/xen-netback/xenbus.c
> >> +++ b/drivers/net/xen-netback/xenbus.c
> >> @@ -265,6 +265,8 @@ static void frontend_changed(struct xenbus_device *dev,
> >>  		break;
> >>  
> >>  	case XenbusStateClosed:
> >> +		if (dev->state == XenbusStateConnected)
> >> +			disconnect_backend(dev);
> > 
> > Could you please add a comment above this change stating that this is a
> > workaround for some old frontend that we cannot fix / upgrade.
> 
> Handling frontend CONNECTED -> CLOSED is a sensible thing for a backend
> to do regardless of whether there are old frontends that do this or not.
> 

I agree handling connected -> closed is sensible here based on the fact
that old frontends could do such state change. However If the state
machine was documented well enough then I think connected -> closed
would not be considered sensible.

This code snippet without comment will cause confusion / encourage wrong
usage of state machine if someone comes here for reference.

> > We would still like to later frontend goes through the normal connected
> > -> closing -> closed path.
> 
> This should be documented as a full description of the two state
> machines in public/io/netif.h in Xen.  Not scattered about in comments

Sure.

> in a particular backend implementation.
> 

The comment in implementation is still worthwhile in case someone comes
here for reference and gets confused.

Wei.

> David
