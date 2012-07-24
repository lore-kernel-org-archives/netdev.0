From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Tue, 24 Jul 2012 16:16:30 +0200
Message-ID: <1343139390.4415.31.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
	 <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
	 <1326704259.3510.3.camel@jlt3.sipsolutions.net>
	 <CAPXgP12gM3_OVuxQAkRRarH_TpjVpbh5NpcTPWL0nEi4eoX+kw@mail.gmail.com>
	 <1326716209.3510.7.camel@jlt3.sipsolutions.net>
	 <CAPXgP13xJNx0v9waZx6m47Ye7q71GGz3A3DoQzb=qszHnOkArw@mail.gmail.com>
	 (sfid-20120719_124643_767103_5E67814F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Kay Sievers <kay@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:39362 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490Ab2GXOQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 10:16:32 -0400
In-Reply-To: <CAPXgP13xJNx0v9waZx6m47Ye7q71GGz3A3DoQzb=qszHnOkArw@mail.gmail.com> (sfid-20120719_124643_767103_5E67814F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 12:46 +0200, Kay Sievers wrote:

> >> > What I'm was asking then is this: Can udev know that it is running from
> >> > initramfs (presumably that can't be too hard) and simply not reply to
> >> > async requests it doesn't have firmware for? Then once the real root is
> >> > mounted it could satisfy (or not) firmware requests from the real root.
> >>
> >> We can surely change it to not cancel the firmware request.
> >>
> >> Either by making it aware that we run from initramfs, or by never
> >> cancelling any firmware request and just leave it hanging around for
> >> forever?
> 
> Never say 6 months is a long time to reply. :)

Hehe :-)

> Fedora uses systemd in the initramfs now, which made it trivial to
> implement this, and to leave the firmware requests hanging around
> until we reach in the real rootfs and know if the firmware file is
> available:
>   http://cgit.freedesktop.org/systemd/systemd/commit/?id=39177382a4f92a834b568d6ae5d750eb2a5a86f9
> 
> The logic to tell udev that it runs in the initramfs could easily be
> implemented by other initramfs tools than dracut, but they usually do
> not really follow what we do here, so this might for now only work on
> recent systems using dracut.

Ok, too bad there wasn't a generic way, but at least there's a way
now :-)

Anyway, I think this is a good thing.

johannes
