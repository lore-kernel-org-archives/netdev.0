From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v3 1/1] xen-netback: Handle backend state
 transitions in a more robust way
Date: Tue, 24 Sep 2013 15:30:36 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0111C7D@AMSPEX01CL01.citrite.net>
References: <1380034282-11210-1-git-send-email-paul.durrant@citrix.com>
 <1380034282-11210-2-git-send-email-paul.durrant@citrix.com>
 <20130924152611.GA14211@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48190 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096Ab3IXPei convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:34:38 -0400
In-Reply-To: <20130924152611.GA14211@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 24 September 2013 16:26
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Ian Campbell; Wei Liu;
> David Vrabel
> Subject: Re: [PATCH net v3 1/1] xen-netback: Handle backend state
> transitions in a more robust way
> 
> On Tue, Sep 24, 2013 at 03:51:22PM +0100, Paul Durrant wrote:
> > When the frontend state changes metback now specifies its desired state
> to
>                                   netback
> > a new function, set_backend_state(), which transitions through any
> [...]
> > +/* Handle backend state transitions:
> > + *
> > + * The backend state starts in InitWait and the following transtions are
>                                                              transitions
> > + * allowed.
> >
> [...]
> > @@ -363,7 +448,9 @@ static void hotplug_status_changed(struct
> xenbus_watch *watch,
> >  	if (IS_ERR(str))
> >  		return;
> >  	if (len == sizeof("connected")-1 && !memcmp(str, "connected", len))
> {
> > -		xenbus_switch_state(be->dev, XenbusStateConnected);
> > +		/* Complete any pending state change */
> > +		xenbus_switch_state(be->dev, be->state);
> > +
> 
> The state transition takes place iff hotplug status is "connected", is
> this desirable? What if hotplug fails?
> 

The xenbus state will remain in InitWait but the backend state will be Connected.

> If it cycles through connect again it looks like it will trigger that
> BUG_ON in connect()?
> 

No, I don't think so because be->state is not the same as dev->state. The frontend can go to Closing/Closed (which will take dev->state to Closing/Closed) and this should be fine.

  Paul
