From: Elliot Schwartz <elliot@devicescape.com>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Mon, 28 Aug 2006 11:34:15 -0700
Message-ID: <upsekwvyw.fsf@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
	<20060822173419.GF12500@devicescape.com>
	<1156317906.3629.18.camel@ux156>
	<20060823180912.2f06d469@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:11500 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751317AbWH1SeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 14:34:21 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060823180912.2f06d469@griffin.suse.cz> (Jiri Benc's message
 of "Wed, 23 Aug 2006 18:09:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Jiri (and Johannes),

Jiri Benc <jbenc@suse.cz> writes:
> On Wed, 23 Aug 2006 09:25:06 +0200, Johannes Berg wrote:
> > Should that really drop dataframes dead on the floor? And wouldn't it
> > make sense stop the networking layer from injecting more data into the
> > stack when stop_data_frame_tx is enabled?
>
> I agree. That should be solved in an another way (stop dequeuing frames
> from 802.11 qdisc?).

This is used to be able to send the channel switch announcements that
are queued from userspace out, yet not send dataframes in this same
queue out. This is to avoid exceeding regulatory requirements for
transmission time after radar has been detected.

It's not ideal, but possibly neither is hanging on to the frames
during the interval in which the channel changes hoping to find the
same station there.

Thanks,

elliot


