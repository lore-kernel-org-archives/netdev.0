From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [PATCH 3/3] pm_qos: get rid of the allocation in
 pm_qos_add_request()
Date: Mon, 05 Jul 2010 09:02:48 -0500
Message-ID: <1278338568.2850.1.camel@mulgrave.site>
References: <1277746434.10879.191.camel@mulgrave.site>
	 <1277747088.10879.201.camel@mulgrave.site>  <s5hvd8ubfcz.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux PM <linux-pm@lists.linux-foundation.org>,
	markgross@thegnar.org, netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47483 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032Ab0GEOCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 10:02:54 -0400
In-Reply-To: <s5hvd8ubfcz.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-05 at 08:41 +0200, Takashi Iwai wrote:
> sorry for the late reply, as I've been on vacation in the last week
> (and shut off mails intentionally :)

Envy forbids me from saying that's OK.

> At Mon, 28 Jun 2010 12:44:48 -0500,
> James Bottomley wrote:
> > 
> > Since every caller has to squirrel away the returned pointer anyway,
> > they might as well supply the memory area.  This fixes a bug in a few of
> > the call sites where the returned pointer was dereferenced without
> > checking it for NULL (which gets returned if the kzalloc failed).
> > 
> > I'd like to hear how sound and netdev feels about this: it will add
> > about two more pointers worth of data to struct netdev and struct
> > snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> > your acks and send through the pm tree.
> > 
> > This also looks to me like an android independent clean up (even though
> > it renders the request_add atomically callable).  I also added include
> > guards to include/linux/pm_qos_params.h
> 
> I like the patch very well, too.
> But, just wondering...
> 
> > @@ -262,6 +260,11 @@ void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> >  	if (!pm_qos_req) /*guard against callers passing in null */
> >  		return;
> >  
> > +	if (pm_qos_request_active(pm_qos_req)) {
> > +		WARN(1, KERN_ERR "pm_qos_update_request() called for unknown object\n");
> > +		return;
> > +	}
> > +
> 
> Is this correct...?  Shouldn't it be a negative check?

Yes, it should be a negative check ... I'll update the patch.  I guess
this still means that no-one has managed to test it on a functional
system ...

James


