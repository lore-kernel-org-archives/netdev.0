From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Mon, 16 Jan 2012 13:16:49 +0100
Message-ID: <1326716209.3510.7.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
	 <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
	 <1326704259.3510.3.camel@jlt3.sipsolutions.net>
	 <CAPXgP12gM3_OVuxQAkRRarH_TpjVpbh5NpcTPWL0nEi4eoX+kw@mail.gmail.com>
	 (sfid-20120116_130612_776092_70A618B1)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46810 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab2APMQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 07:16:52 -0500
In-Reply-To: <CAPXgP12gM3_OVuxQAkRRarH_TpjVpbh5NpcTPWL0nEi4eoX+kw@mail.gmail.com> (sfid-20120116_130612_776092_70A618B1)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-16 at 13:05 +0100, Kay Sievers wrote:

> > What I'm was asking then is this: Can udev know that it is running from
> > initramfs (presumably that can't be too hard) and simply not reply to
> > async requests it doesn't have firmware for? Then once the real root is
> > mounted it could satisfy (or not) firmware requests from the real root.
> 
> We can surely change it to not cancel the firmware request.
> 
> Either by making it aware that we run from initramfs, or by never
> cancelling any firmware request and just leave it hanging around for
> forever?

I think not cancelling it from initramfs and then providing or
cancelling it once we have normal root mounted should be sufficient? I
don't see how letting it hang around forever (a minute until it times
out) would be useful.

> We need to decide what's the best model here, if we want a timeout at
> all, if yes, how large it should be, and if and when we should cancel
> requests.

I do think cancelling requests still gives us desirable behaviour in
terms of being able to reproduce it etc., it's just that cancelling it
when we have only partial data (from initramfs) isn't helpful.

johannes
