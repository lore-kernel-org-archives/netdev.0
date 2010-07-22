From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Thu, 22 Jul 2010 19:44:37 +0200
Message-ID: <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
References: <20100621222938.GA20583@suse.de> <m1eig0dmhk.fsf@fess.ebiederm.org>
	<20100621231058.GA1066@suse.de> <m14ogwc4ou.fsf@fess.ebiederm.org>
	<20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com> <20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org> <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<m1vd87toy9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54034 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab0GVRoz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 13:44:55 -0400
Received: by wyf19 with SMTP id 19so824146wyf.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 10:44:54 -0700 (PDT)
In-Reply-To: <m1vd87toy9.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 19:18, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Kay Sievers <kay.sievers@vrfy.org> writes:

> Let me get this straight. =C2=A0You believe a non-trival non-obvious
> complete rewrite of entire subsystems after rc1 is better than
> a one line bug fix that let's real hardware work for real
> people?

Yes. The drivers are broken in its core use pattern, and enabling a
(non-common) new feature exposes this. Users should just not enable
the new feature until the drivers, they might depend on, are fixed
properly. That's the rule for all other kernel development too, and I
don't see what's different here. It's not a regression, and not a bug
in the core, which needs fixing.

I don't see what would justify subsystem-specific hacks in the core,
which we will never be able to remove. Your patch exposes sysfs device
layout for a single subsystem in an unusual manner, and we can not
change that later. We need to avoid such special cases for all
reasons.

> You have had 3 years to do better a better job with the bluetooth
> driver.

I don't know of any real-world problem here.

> Furthermore we fixed the rest of this regression in the core I don't
> see why we can fix the entirety of it this namespace regression in th=
e
> core. =C2=A0Especially since it is an obviously correct one line chan=
ge.

Oh, no. It's obviously wrong to add specific lists of subsystems to
generic core code to fix individual drivers. It even implements its
own sysfs layout rules for a single subsystem.

Please help fixing the drivers, or improving the core where needed, to
support these drivers better, but don't try to throw quick and dirty
and wrong fixes at us. Sysfs is already hard to understand and more
exceptions like this, and subsystem-specific layout rules would
seriously be the wrong direction.

Thanks,
Kay
