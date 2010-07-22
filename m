From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Thu, 22 Jul 2010 17:30:18 +0200
Message-ID: <AANLkTikYcaZmtvjN1Ah2v2hLcAloLGyhiHPAYLatP5tn@mail.gmail.com>
References: <20100621222938.GA20583@suse.de> <m1eig0dmhk.fsf@fess.ebiederm.org>
	<20100621231058.GA1066@suse.de> <m14ogwc4ou.fsf@fess.ebiederm.org>
	<20100622035631.GA3755@suse.de> <m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com> <20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1zkxj27xp.fsf_-_@fess.ebiederm.org> <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
	<1279807845.12439.20.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:40105 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab0GVPae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 11:30:34 -0400
Received: by pxi14 with SMTP id 14so3209022pxi.19
        for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 08:30:34 -0700 (PDT)
In-Reply-To: <1279807845.12439.20.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 16:10, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Thu, 2010-07-22 at 15:38 +0200, Kay Sievers wrote:
>>
>> Please try to fix these drivers instead, or mark the broken for
>> namespaces, if nobody can fix them right now.
>
> We've tried. Nobody, including you, has been able to suggest how to fix
> it.

I did, and several times. Here are the options again:

- Split the driver in two modules, so the auto-cleanup of the netdev
can be done by the second module when the device is force-unloaded
without taking any references to the code while in use (netdev specif
behavior).

- Move the device cleanup code somehow in the core by adding proper
functions to bus devices, similar to the completely mis-used
device_create() function for class devices. This would also be a
proper fix for the weird driver core use.

- Do not allow to force-unload the module while the netdev is in use.
You would need some "destruct" command for the device then, which
removes the netdev, and to be able to unload the module.

> And it's not just broken with network namespaces enabled either, as

So what's the problem without the sysfs ns then? I didn't hear any the
last couple of years.

> Eric explained. I really don't see why you keep asking us to fix it when
> clearly we cannot -- even you don't know how and you certainly have more
> insight into the device model than we do.

Sure, and I ask again to fix the drivers, instead of sneaking-in dirty
hacks into the core, just by calling an expected behavior a
"regression". This is not a core bug, and should not be worked around
that way in the core.

If there is a new requirement for the core (like possibly point 2
above), we can surely look into making this happen.

We can not add lists of individual subsystems to generic core
functions to work around broken drivers. I hope you will understand
that.

Thanks,
Kay
