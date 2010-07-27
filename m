From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Tue, 27 Jul 2010 20:54:33 +0200
Message-ID: <AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de> <1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com> <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com> <m1zkxcg3xe.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61975 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab0G0Syt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 14:54:49 -0400
Received: by qyk7 with SMTP id 7so2885069qyk.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 11:54:48 -0700 (PDT)
In-Reply-To: <m1zkxcg3xe.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 20:44, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Greg KH <greg@kroah.com> writes:
>> On Tue, Jul 27, 2010 at 08:24:31PM +0200, Kay Sievers wrote:
>>> On Tue, Jul 27, 2010 at 20:17, Eric W. Biederman <ebiederm@xmission=
=2Ecom> wrote:
>>> > Greg KH <greg@kroah.com> writes:
>>>
>>> > Let me say this again clearly.
>>> >
>>> > class -> bus BROKEN
>>> >
>>> > In the case of bluetooth it would require changing /sys/class/blu=
etooth
>>> > to /sys/bus/bluetooth. ??Which is user visible in the worst possi=
ble
>>> > way and quick google search confirmed it will break user space sc=
ripts.
>>>
>>> Clearly, we even have a compat API for that, and nothing would brea=
k.
>>> If needed, a bus can create compat class links. Did you even check
>>> with the bluetooth guys, last time I talked to them, they have been
>>> totally fine with such a change.
>
> Hmm. =C2=A0It appears I missed the compat API in my review of the bus=
 code.
> Could I get a pointer?

It's:
  class_compat_create_link()
  http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
blob;f=3Ddrivers/base/class.c;h=3D8e231d05b40058c6c3191b4a06a15ceff1714=
be3;hb=3DHEAD#l559

I think i2c uses this when the class was converted to a bus.

It should only be used if it's really needed for known used userspace
interfaces. A few others that got converted already did not need it.

Kay
