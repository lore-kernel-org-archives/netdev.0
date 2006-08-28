From: Elliot Schwartz <elliot@devicescape.com>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Mon, 28 Aug 2006 11:29:24 -0700
Message-ID: <uwt8sww6z.fsf@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
	<20060822173419.GF12500@devicescape.com>
	<1156317906.3629.18.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:26091 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751196AbWH1S3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 14:29:50 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156317906.3629.18.camel@ux156> (Johannes Berg's message of
 "Wed, 23 Aug 2006 09:25:06 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Johannes,

Johannes Berg <johannes@sipsolutions.net> writes:
> On Tue, 2006-08-22 at 10:34 -0700, David Kimdon wrote:
> > This ioctl is used when radar is delected on a channel.  Data
> > frames must stop but management frames must be allowed to continue
> > for some time to communicate the channel switch to stations.
>
> Which does lead to the question: How are you detecting radar in
> userspace in the first place??

I've been working on merging Devicescape's 802.11h / radar detection
implementation into the open source hostapd (and the wireless-dev kernel). 

Radar is initially detected by the low-level radio driver.  Userspace
gets notified of radar via calls to ieee80211_radar_status, which
generates a "fake" management frame with a struct ieee80211_radar_info
in it.  Userspace is then responsible for handling the resultant
activities, such as stopping transmission on that channel, selecting
another channel, sending out channel switch announcements, changing
channels, and remembering to block use of the old channel for the
required time.

I'll reply to your and Jiri's other question separately.

Thanks,

elliot


