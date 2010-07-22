From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename  regression
Date: Thu, 22 Jul 2010 10:18:38 -0700
Message-ID: <m1vd87toy9.fsf@fess.ebiederm.org>
References: <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
	<20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org>
	<AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53458 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab0GVRSr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 13:18:47 -0400
In-Reply-To: <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com> (Kay Sievers's message of "Thu\, 22 Jul 2010 15\:38\:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kay Sievers <kay.sievers@vrfy.org> writes:

Kay you are full of it.  My argument is that this a clear case
where aiming for perfection is the enemy of the good.

>> --- a/drivers/base/core.c
>> +++ b/drivers/base/core.c
>> @@ -673,7 +673,7 @@ static struct kobject *get_device_parent(struct =
device *dev,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (parent =3D=
=3D NULL)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0parent_kobj =3D virtual_device_parent(dev);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (parent->=
class)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (parent->=
class && (strcmp(dev->class->name, "net") !=3D 0))
>

> Since the issue is not a regression, and not even a bug in the core,
> it should not be done this way for mainline.

Yes the issue is a namespace regression and it has been a regression
for the bluetooth network drivers since CONFIG_SYSFS_DEPRECATED was
introduced.  "ip link set name blarg"  Where blarg is an attribute of
the bluteooth parent device fails only with CONFIG_SYSFS_DEPRECATED
disabled.

I reported that regression for the majority of the network devices and
the class directories were introduced to avoid this problem, except
convoluted logic of when to create a class directory fails to cover
a few flavors of network drivers.

=46or the mac80211_hwsim driver I don't care.  That isn't real hardware
and it is only interesting for testing.  For the bluetooth network driv=
er
that is real hardware that needs to be made to work.

> Please try to fix these drivers instead, or mark the broken for
> namespaces, if nobody can fix them right now.

Let me get this straight.  You believe a non-trival non-obvious
complete rewrite of entire subsystems after rc1 is better than
a one line bug fix that let's real hardware work for real
people?

You have had 3 years to do better a better job with the bluetooth
driver.

=46urthermore we fixed the rest of this regression in the core I don't
see why we can fix the entirety of it this namespace regression in the
core.  Especially since it is an obviously correct one line change.

Eric




