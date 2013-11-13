From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Wed, 13 Nov 2013 19:30:22 +0100
Message-ID: <1384367422.14578.20.camel@jlt4.sipsolutions.net>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	 <1384160932.14334.6.camel@jlt4.sipsolutions.net>
	 <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	 <1384184624.14334.31.camel@jlt4.sipsolutions.net>
	 <CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	 <1384188067.14334.45.camel@jlt4.sipsolutions.net>
	 <CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
	 <1384189227.14334.48.camel@jlt4.sipsolutions.net>
	 <CAMP44s1yJMd+9G5yu988GqafRYnAteN-y-WWDe-rJh_qQpSPkQ@mail.gmail.com>
	 (sfid-20131111_190659_870378_D4E90928)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:45245 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759446Ab3KMSaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 13:30:30 -0500
In-Reply-To: <CAMP44s1yJMd+9G5yu988GqafRYnAteN-y-WWDe-rJh_qQpSPkQ@mail.gmail.com> (sfid-20131111_190659_870378_D4E90928)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 12:06 -0600, Felipe Contreras wrote:

> > The not receiving part is a bug. I think you're probably receiving
> > beacons once associated though?
> 
> Nope. Never.

That's odd, firmware bug? But it's still odd since windows works?

> Moreover, if continuing the association without beacons has a legal a
> problem, that problem would exist for drivers that don't have the
> IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC flag, wouldn't it? How exactly
> would trying to associate with need_beacon break the law, but not if
> !need_beacon?

Well, it's actually somewhat unlikely you'd break the law, although
possible, since eventually you'd get disconnected from the AP anyway?

In any case - your argumentation above isn't true because every device
listens for beacons, and if none are received then it should eventually
disconnect. That should be true even with your hack here.

In any case, I'm not really comfortable connecting to an AP that we
never ever receive beacons from. I can try to investigate why this
doesn't happen on windows and what we should be doing though.

johannes
