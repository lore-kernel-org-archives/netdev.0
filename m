From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [linux-pm] [PATCH 3/3] pm_qos: get rid of the allocation in
 pm_qos_add_request()
Date: Mon, 28 Jun 2010 17:10:49 -0500
Message-ID: <1277763049.10879.204.camel@mulgrave.site>
References: <1277746434.10879.191.camel@mulgrave.site>
	 <1277747088.10879.201.camel@mulgrave.site> <201006282359.18045.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, markgross@thegnar.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55713 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab0F1WKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 18:10:55 -0400
In-Reply-To: <201006282359.18045.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-28 at 23:59 +0200, Rafael J. Wysocki wrote:
> On Monday, June 28, 2010, James Bottomley wrote:
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
> > 
> > cc: netdev@vger.kernel.org
> > cc: Takashi Iwai <tiwai@suse.de>
> > Signed-off-by: James Bottomley <James.Bottomley@suse.de>
> 
> I like all of the patches in this series, thanks a lot for doing this!
> 
> I guess it might be worth sending a CC to the LKML next round so that people
> can see [1/3] (I don't expect any objections, but anyway it would be nice).

I cc'd the latest owners of plist.h ... although Daniel Walker has
apparently since left MontaVista, Thomas Gleixner is still current ...
and he can speak for the RT people, who are the primary plist users.

I can do another round and cc lkml, I was just hoping this would be the
last revision.

James


