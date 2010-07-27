From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename  regression
Date: Tue, 27 Jul 2010 13:53:02 -0700
Message-ID: <m1aapcejf5.fsf@fess.ebiederm.org>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com> <m1zkxcg3xe.fsf@fess.ebiederm.org>
	<AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43373 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905Ab0G0UxJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 16:53:09 -0400
In-Reply-To: <AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com> (Kay Sievers's message of "Tue\, 27 Jul 2010 20\:54\:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kay Sievers <kay.sievers@vrfy.org> writes:

> On Tue, Jul 27, 2010 at 20:44, Eric W. Biederman <ebiederm@xmission.c=
om> wrote:
>> Greg KH <greg@kroah.com> writes:
>>> On Tue, Jul 27, 2010 at 08:24:31PM +0200, Kay Sievers wrote:
>>>> On Tue, Jul 27, 2010 at 20:17, Eric W. Biederman <ebiederm@xmissio=
n.com> wrote:
>>>> > Greg KH <greg@kroah.com> writes:
>>>>
>>>> > Let me say this again clearly.
>>>> >
>>>> > class -> bus BROKEN
>>>> >
>>>> > In the case of bluetooth it would require changing /sys/class/bl=
uetooth
>>>> > to /sys/bus/bluetooth. ??Which is user visible in the worst poss=
ible
>>>> > way and quick google search confirmed it will break user space s=
cripts.
>>>>
>>>> Clearly, we even have a compat API for that, and nothing would bre=
ak.
>>>> If needed, a bus can create compat class links. Did you even check
>>>> with the bluetooth guys, last time I talked to them, they have bee=
n
>>>> totally fine with such a change.
>>
>> Hmm. =C2=A0It appears I missed the compat API in my review of the bu=
s code.
>> Could I get a pointer?
>
> It's:
>   class_compat_create_link()
>   http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dblob;f=3Ddrivers/base/class.c;h=3D8e231d05b40058c6c3191b4a06a15ceff=
1714be3;hb=3DHEAD#l559
>
>
> I think i2c uses this when the class was converted to a bus.

> It should only be used if it's really needed for known used userspace
> interfaces. A few others that got converted already did not need it.

Interesting.  The symlink creation is slightly buggy in that it is
created after the uevent for device creation has been sent.  Which can
lead to some interesting races in userspace.

As for the rest the bus compat code is similar but not quite the same
as the class code, so I would be extremely reluctant to deploy it
except in extremely limited cases.  Backwards compatibility is
important, and we should strive our best to maintain backwards
compatibility it for the kernel<->userspace ABIs.

Eric
