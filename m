From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 18:00:27 +0100
Message-ID: <1384189227.14334.48.camel@jlt4.sipsolutions.net>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	 <1384160932.14334.6.camel@jlt4.sipsolutions.net>
	 <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	 <1384184624.14334.31.camel@jlt4.sipsolutions.net>
	 <CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	 <1384188067.14334.45.camel@jlt4.sipsolutions.net>
	 <CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
	 (sfid-20131111_175400_478164_6AC66036)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36786 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab3KKRAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 12:00:35 -0500
In-Reply-To: <CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com> (sfid-20131111_175400_478164_6AC66036)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 10:53 -0600, Felipe Contreras wrote:

> > I see the same behaviour - but it's the supplicant's doing, it is indeed
> > getting the event that the AP connection failed (timed out):
> >
> > wlan0: Event ASSOC_TIMED_OUT (15) received
> 
> Not in my setup.

Well, dunno then. Different kernel versions? This clearly happens for
me.

> >> > This isn't really true like I said above - the kernel can only drop the
> >> > association, if userspace *insists* then it will try again and again.
> >>
> >> But it's not doing this:
> >>
> >>   ieee80211_destroy_assoc_data(sdata, false);
> >>   cfg80211_assoc_timeout(sdata->dev, bss);
> >>
> >> Which is what causes the association to stop for me.
> >>
> >> So where exactly in the code is the association being "dropped"?
> >
> > This does get called in my setup.
> 
> Yes, because your setup is receiving beacons.

No ... I tested on hwsim, making it ask for dtim-before-assoc, and
short-circuiting the beacon-TX routing. It can't have been seeing
beacons.

> Check the code:
> 
> if ((ifmgd->assoc_data->need_beacon && !ifmgd->have_beacon) ||
>    ieee80211_do_assoc(sdata)) {
> struct cfg80211_bss *bss = ifmgd->assoc_data->bss;
> 
> ieee80211_destroy_assoc_data(sdata, false);
> cfg80211_assoc_timeout(sdata->dev, bss);
> }
> 
> If there's no beacon, cfg80211_assoc_timeout() is not called.

Yes it is.

"need_beacon && !have_beacon:

means - I wanted the beacon but didn't get it at the timeout.

> I'm sure if you don't call ieee80211_rx_mgmt_beacon() at all you will
> see the same behavior I see.

I'm sure I won't :)

> > Like I said before - trying to work with an AP without beacons at all is
> > really bad, we shouldn't be doing it.
> 
> Why not? For all intents and purposes my system is not receiving any
> beacons, and I don't see any problems.

The not receiving part is a bug. I think you're probably receiving
beacons once associated though?

> What would you prefer? That nothing works at all?

Yes, that'd be much safer.

> > We might not properly react to
> > radar events, and other things, for example.
> 
> So? I don't know what that means, but it can't be worst than not being
> able to connect to the Internet whatsoever at all.

It can make you break the law.

johannes
