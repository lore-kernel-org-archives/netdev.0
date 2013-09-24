From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v3 1/1] xen-netback: Handle backend state transitions
 in a more robust way
Date: Tue, 24 Sep 2013 16:26:12 +0100
Message-ID: <20130924152611.GA14211@zion.uk.xensource.com>
References: <1380034282-11210-1-git-send-email-paul.durrant@citrix.com>
 <1380034282-11210-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58545 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab3IXP0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:26:13 -0400
Content-Disposition: inline
In-Reply-To: <1380034282-11210-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 03:51:22PM +0100, Paul Durrant wrote:
> When the frontend state changes metback now specifies its desired state to
                                  netback
> a new function, set_backend_state(), which transitions through any
[...]
> +/* Handle backend state transitions:
> + *
> + * The backend state starts in InitWait and the following transtions are
                                                             transitions
> + * allowed.
>  
[...]
> @@ -363,7 +448,9 @@ static void hotplug_status_changed(struct xenbus_watch *watch,
>  	if (IS_ERR(str))
>  		return;
>  	if (len == sizeof("connected")-1 && !memcmp(str, "connected", len)) {
> -		xenbus_switch_state(be->dev, XenbusStateConnected);
> +		/* Complete any pending state change */
> +		xenbus_switch_state(be->dev, be->state);
> +

The state transition takes place iff hotplug status is "connected", is
this desirable? What if hotplug fails?

If it cycles through connect again it looks like it will trigger that
BUG_ON in connect()?

Wei.
