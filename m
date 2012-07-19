From: Kay Sievers <kay@vrfy.org>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Thu, 19 Jul 2012 12:46:20 +0200
Message-ID: <CAPXgP13xJNx0v9waZx6m47Ye7q71GGz3A3DoQzb=qszHnOkArw@mail.gmail.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
 <1326621743.3448.1.camel@jlt3.sipsolutions.net> <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
 <1326704259.3510.3.camel@jlt3.sipsolutions.net> <CAPXgP12gM3_OVuxQAkRRarH_TpjVpbh5NpcTPWL0nEi4eoX+kw@mail.gmail.com>
 <1326716209.3510.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53867 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748Ab2GSKqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 06:46:42 -0400
Received: by gglu4 with SMTP id u4so2589701ggl.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 03:46:41 -0700 (PDT)
In-Reply-To: <1326716209.3510.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2012 at 1:16 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2012-01-16 at 13:05 +0100, Kay Sievers wrote:
>
>> > What I'm was asking then is this: Can udev know that it is running from
>> > initramfs (presumably that can't be too hard) and simply not reply to
>> > async requests it doesn't have firmware for? Then once the real root is
>> > mounted it could satisfy (or not) firmware requests from the real root.
>>
>> We can surely change it to not cancel the firmware request.
>>
>> Either by making it aware that we run from initramfs, or by never
>> cancelling any firmware request and just leave it hanging around for
>> forever?

Never say 6 months is a long time to reply. :)

Fedora uses systemd in the initramfs now, which made it trivial to
implement this, and to leave the firmware requests hanging around
until we reach in the real rootfs and know if the firmware file is
available:
  http://cgit.freedesktop.org/systemd/systemd/commit/?id=39177382a4f92a834b568d6ae5d750eb2a5a86f9

The logic to tell udev that it runs in the initramfs could easily be
implemented by other initramfs tools than dracut, but they usually do
not really follow what we do here, so this might for now only work on
recent systems using dracut.

Cheers,
Kay
