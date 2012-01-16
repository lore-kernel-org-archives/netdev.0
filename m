From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Mon, 16 Jan 2012 13:05:19 +0100
Message-ID: <CAPXgP12gM3_OVuxQAkRRarH_TpjVpbh5NpcTPWL0nEi4eoX+kw@mail.gmail.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
 <1326621743.3448.1.camel@jlt3.sipsolutions.net> <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
 <1326704259.3510.3.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43932 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2APMFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 07:05:40 -0500
In-Reply-To: <1326704259.3510.3.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2012 at 09:57, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Sun, 2012-01-15 at 16:33 +0100, Kay Sievers wrote:

> Let's say you have iwlwifi, built into the kernel, and an
> initramfs that doesn't contain the iwlwifi firmware.
> What will happen (last I checked anyway) is this: iwlwifi will do an
> async firmware request, and the udev in initramfs will say "don't have
> it", thus unbinding and you have to sysfs bind or module reload.

Right, currently. if no firmware is found, udev will write "-1" to the
"loading" file in /sys, which will cancel the kernel's firmware
request.

> What I'm was asking then is this: Can udev know that it is running from
> initramfs (presumably that can't be too hard) and simply not reply to
> async requests it doesn't have firmware for? Then once the real root is
> mounted it could satisfy (or not) firmware requests from the real root.

We can surely change it to not cancel the firmware request.

Either by making it aware that we run from initramfs, or by never
cancelling any firmware request and just leave it hanging around for
forever?

We need to decide what's the best model here, if we want a timeout at
all, if yes, how large it should be, and if and when we should cancel
requests.

Kay
