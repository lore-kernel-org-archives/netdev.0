From: Jim Wylder <jwylder1@motorola.com>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Sat, 3 Sep 2011 12:32:44 -0500
Message-ID: <CAPopfEWi0v9VXeDYcBfEgnWYxg7WcTTj3GBc6USzwcN+aGrKOQ@mail.gmail.com>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
	<201109031837.48444.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:55405 "EHLO
	exprod5og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab1ICRcr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:32:47 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.176.130.20])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p83HSrKN018035
	for <netdev@vger.kernel.org>; Sat, 3 Sep 2011 13:28:54 -0400 (EDT)
Received: from mail-wy0-f170.google.com (mail-wy0-f170.google.com [74.125.82.170])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p83HSXi6018004
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 3 Sep 2011 13:28:53 -0400 (EDT)
Received: by mail-wy0-f170.google.com with SMTP id 23so3326133wyf.15
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2011 10:32:44 -0700 (PDT)
In-Reply-To: <201109031837.48444.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver,

Thanks for the quick feedback.  True usbnet_start_xmit() could be
running at anytime, but the usb_autopm_get_interface_async() will only
return -EINPROGRESS when rpm_resume detects that
dev->power.runtime_status =3D=3D RPM_RESUMING.  My understanding is tha=
t
for an asynchronous request, the promise that the device is resuming
would be equivalent to cases where usb_autopm_get_interface_async()
returns success.

In all other cases, when we are not attempting to resume an already
resuming interface, this change should have no impact.

Are you recommending that I add an additional check for DEV_ASLEEP,
possibly to decide whether to drop the or continue on?  Or am I
missing your point?  I had not done anything similar because my
understanding was that knowing that the device is in fact resuming
would be sufficient.

Jim

On Sat, Sep 3, 2011 at 11:37 AM, Oliver Neukum <oliver@neukum.org> wrot=
e:
> Am Samstag, 3. September 2011, 16:21:00 schrieb Jim Wylder:
>> When calling pm_runtime_get, usb_autopm_get_interface_async
>> treats a return value of -EINPROGRESS as a success and
>> increments the usage count. =A0Since the interface is resuming,
>> it is safe for usbnet_start_xmit to submit the urb.
>
> usbnet_start_xmit() is exported, so simply stating that it is
> called when the interface is resumingisn't enough. It seems to
> me that the later check for DEV_ASLEEP will save as, but have
> you checked for that?
>
> =A0 =A0 =A0 =A0Regards
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Oliver
>
