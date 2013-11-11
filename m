From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 04:59:40 -0600
Message-ID: <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:53872 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab3KKK7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 05:59:42 -0500
In-Reply-To: <1384160932.14334.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 3:08 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Sun, 2013-11-10 at 15:45 -0600, Felipe Contreras wrote:
>> We don't want to be waiting forever for a beacon that will never come,
>> just continue the association.
>
> This makes no sense, IMO.
>
> If there really are no beacons at all, then nothing can work with the AP
> -- things like HT, regulatory/radar, powersave, multiple virtual
> interfaces and many others require beacons.

Well the AP is sending beacons, but they seem to be corrupted,
although the corruption often seems to happen in a place that is not
so important.

No other device at this house seems to have a problem with that, even
the Intel driver in Windows doesn't have a problem, it's just the
driver in Linux.

However, if I apply this patch, I don't notice any issue, it
associates and works fine. Maybe there's some subtle issues with
features I don't personally use, or perhaps there's the occasional
disconnection (although that could be due to something else), but
that's light years away from not associating at all.

I'd say between a) some features not working and b) nothing working at
all, a) is preferred.

If you think it's better that nothing works at all, then wouldn't it
make sense to time out and return an error? Currently we just keep
trying to associate *forever*.

> If the AP is sending beacons but the device isn't receiving them, then
> it's a driver bug and mac80211 shouldn't work around it.

I agree, but I can't seem to convince Intel guys of that. The firmware
is dropping the corrupt beacon frames (although not always), so
there's nothing the driver can do afterwards.

But even if there were not beacons at all (corrupt or otherwise), I
still think waiting *forever* in a loop is not ideal, a) is preferred;
not having all the features, but still somehow work (from my point of
view it's more than somewhat).

-- 
Felipe Contreras
