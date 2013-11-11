From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 16:43:44 +0100
Message-ID: <1384184624.14334.31.camel@jlt4.sipsolutions.net>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	 <1384160932.14334.6.camel@jlt4.sipsolutions.net>
	 <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	 (sfid-20131111_115941_636478_ABBFA0BB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36524 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab3KKPn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:43:56 -0500
In-Reply-To: <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com> (sfid-20131111_115941_636478_ABBFA0BB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 04:59 -0600, Felipe Contreras wrote:

> Well the AP is sending beacons, but they seem to be corrupted,
> although the corruption often seems to happen in a place that is not
> so important.

Indeed - the beacon you sent to me in private is damaged somewhere
towards the end of the frame. Are we actually receiving it but ignoring
it because it doesn't have the data we need? The firmware still
shouldn't be filtering anything since it doesn't really look at the
beacon information (or maybe it filters based on the DS IE? I'm not
entirely sure)

> No other device at this house seems to have a problem with that, even
> the Intel driver in Windows doesn't have a problem, it's just the
> driver in Linux.

The windows driver has some slightly different behaviour - it pretends
to be associated towards the firmware before that's actually true, iirc.

> However, if I apply this patch, I don't notice any issue, it
> associates and works fine. Maybe there's some subtle issues with
> features I don't personally use, or perhaps there's the occasional
> disconnection (although that could be due to something else), but
> that's light years away from not associating at all.
> 
> I'd say between a) some features not working and b) nothing working at
> all, a) is preferred.
> 
> If you think it's better that nothing works at all, then wouldn't it
> make sense to time out and return an error? Currently we just keep
> trying to associate *forever*.

That's wpa_supplicant/userspace behaviour. The kernel will just drop the
connection.

> > If the AP is sending beacons but the device isn't receiving them, then
> > it's a driver bug and mac80211 shouldn't work around it.
> 
> I agree, but I can't seem to convince Intel guys of that. The firmware
> is dropping the corrupt beacon frames (although not always), so
> there's nothing the driver can do afterwards.

You realize I work for the same team in Intel as well? :)

> But even if there were not beacons at all (corrupt or otherwise), I
> still think waiting *forever* in a loop is not ideal, a) is preferred;
> not having all the features, but still somehow work (from my point of
> view it's more than somewhat).

This isn't really true like I said above - the kernel can only drop the
association, if userspace *insists* then it will try again and again.

I'd much rather try to get to the bottom of this. Maybe the firmware is
dropping the beacon because the DS IE is broken? Or are we receiving it
but ignoring it because it's broken?

Unfortunately, there's only so much we can do to work around broken APs.

johannes
