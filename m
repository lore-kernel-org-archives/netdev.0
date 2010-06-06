From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Sun, 6 Jun 2010 19:17:32 +0200
Message-ID: <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com> <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org> <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org> <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org> <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org> <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	<1275634452.5189.1.camel@jlt3.sipsolutions.net> <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	<1275640113.9953.8.camel@jlt3.sipsolutions.net> <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	<1275829701.3615.54.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49926 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756781Ab0FFRRs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 13:17:48 -0400
Received: by gye5 with SMTP id 5so1808983gye.19
        for <netdev@vger.kernel.org>; Sun, 06 Jun 2010 10:17:47 -0700 (PDT)
In-Reply-To: <1275829701.3615.54.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 6, 2010 at 15:08, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> On Fri, 2010-06-04 at 10:34 +0200, Kay Sievers wrote:
>> Actually there is not much reason to ever use "struct class" today.
>> The layout for classes in /sys is not extendable like it is for buse=
s
>> which put all devices in a devices/ subdir and have the main subsyst=
em
>> directory to add custom things.
>
> Ok, I don't get it.
>
> For hwsim, we create entirely virtual "struct device"s. I think we ju=
st
> need that so userspace like network-manager doesn't get completely
> confused. BUT: device_create() needs a struct class parameter as the
> first parameter. So should we have a virtual class _and_ a virtual bu=
s??
>
> Similarly for wireless itself (net/wireless/), we use
> device_initialize() and set up the dev.class and dev.platform_data (n=
ot
> sure why platform data?) since this is a virtual abstraction. Basical=
ly
> we want to show in sysfs that
>
> physical device
> =C2=A0+--- (virtual) wireless phy device 1
> =C2=A0 =C2=A0 +--- netdev 1
> =C2=A0 =C2=A0 +--- netdev 2
> =C2=A0 =C2=A0 +--- netdev 3
> =C2=A0+--- (virtual) wireless phy device 2
> =C2=A0 =C2=A0 +--- netdev 4
>
> Although the second wireless phy device is only done by ath9k and wil=
l
> be removed soon. Still we should show that those netdevs all belong t=
o
> the given wireless phy device.
>
> So ... what should I do? How can I do device_create/device_initialize
> without a struct class?

There is no real difference between classes and buses. Actually we're
working on merging them completely inside the kernel. Just declare a
"struct bus_type" instead of a "struct class".

> And why a bus instead? It's not like there are
> devices that need to be discovered and bound to it etc.

Because class devices are not meat to ever have children from other
classes. This is just not what they should be used like.

Also the flat directories in /sys/class/<name>/* are not extendable
with other stuff, and they should not be used for new stuff. You can
never put subsystem-wide properties to that directory without
confusing userspace. That is not a problem at all with buses, as they
have a dedicated devices/ subdir in the bus directory. If there are no
legacy reason, or things which are already a class, and they should
look similar, no new classes should be added to the kernel.

Kay
