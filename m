From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] mac80211_hwsim: Allow managing radios from
 non-initial namespaces
Date: Mon, 09 May 2016 09:30:45 +0200
Message-ID: <1462779045.30690.2.camel@sipsolutions.net>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
	 <1462258398-6749-3-git-send-email-martin@strongswan.org>
	 <1462302992.10444.11.camel@sipsolutions.net>
	 <1462350799.2546.31.camel@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46349 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbcEIHat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 03:30:49 -0400
In-Reply-To: <1462350799.2546.31.camel@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 10:33 +0200, Martin Willi wrote:

> > This changes today's default behaviour of moving the wiphys to the
> > default namespace. Did you intend to destroy them based on the
> > netgroup, i.e. based on the namespace that created them? Actually,
> > maybe they should move back to the namespace that created them, if
> > the namespace they are in is destroyed? But that's difficult, I
> > don't
> > mind this behaviour, but I'm not sure it's what we want by default
> > for radios created in the init_net.
> With the proposed approach I destroy all radios if the owning
> namespace gets deleted, because we probably don't want them landing
> in init_net if they are created from a (unprivileged) userns process.

I agree they shouldn't land in init_net.

> I think this is what other "virtual" interfaces do (gre tunnels, veth
> etc.). If we think of hwsim radios as such a "virtual" device, that
> makes IMO sense to delete them.

Ok, I have no idea what happens there.

> If we want to keep the existing behavior, we could move radios
> belonging to the init_net-associated netgroup back to init_net, that
> shouldn't be too difficult.
> 
> Moving the radio back to the creators namespace would be the most
> consistent behavior, so I'll check how difficult such a reverse
> lookup is. We then would delete the radio only if it is in the
> creators namespace, or if the creators namespace is gone. Does that
> make sense?

It does make sense, but it does also feel a bit complicated. Perhaps
just special-case the init_net case for consistency with the existing
behaviour, and reserve netgroup 0 for that so we can easily check for
it?

johannes
