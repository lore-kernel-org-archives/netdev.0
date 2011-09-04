From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Sun, 4 Sep 2011 12:16:12 +0200
Message-ID: <201109041216.12127.oliver@neukum.org>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com> <201109031837.48444.oliver@neukum.org> <CAPopfEWi0v9VXeDYcBfEgnWYxg7WcTTj3GBc6USzwcN+aGrKOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jim Wylder <jwylder1@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:37739 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab1IDKMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 06:12:51 -0400
In-Reply-To: <CAPopfEWi0v9VXeDYcBfEgnWYxg7WcTTj3GBc6USzwcN+aGrKOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 3. September 2011, 19:32:44 schrieb Jim Wylder:

Hi,

> Thanks for the quick feedback.  True usbnet_start_xmit() could be
> running at anytime, but the usb_autopm_get_interface_async() will only
> return -EINPROGRESS when rpm_resume detects that
> dev->power.runtime_status == RPM_RESUMING.  My understanding is that
> for an asynchronous request, the promise that the device is resuming
> would be equivalent to cases where usb_autopm_get_interface_async()
> returns success.

If CONFIG_PM is set.

> In all other cases, when we are not attempting to resume an already
> resuming interface, this change should have no impact.
> 
> Are you recommending that I add an additional check for DEV_ASLEEP,

The check is already there but depending on CONFIG_PM.

> possibly to decide whether to drop the or continue on?  Or am I
> missing your point?  I had not done anything similar because my
> understanding was that knowing that the device is in fact resuming
> would be sufficient.

At that point it is sufficient. Upon further thought it looks like your check
is correct.
We just need to make very sure that for the decision to queue or
to submit EVENT_DEV_ASLEEP is relevant.
Would you consider defining a macro with a nice name for the
==0 || == -EINPROGRESS check, so that any reader knows what
this is about? This is because I doubt only usbnet is affected.

	Regards
		Oliver
