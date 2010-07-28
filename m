From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Wed, 28 Jul 2010 06:41:52 +0200
Message-ID: <AANLkTimA9Mo0B6MOn31KQ=L+raeCUg6eH3Mqf=vB5AYz@mail.gmail.com>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de> <1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com> <AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com> <m1zkxcg3xe.fsf@fess.ebiederm.org>
	<AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com>
	<m1aapcejf5.fsf@fess.ebiederm.org>
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
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59659 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab0G1EmJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 00:42:09 -0400
Received: by gxk23 with SMTP id 23so1539942gxk.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 21:42:08 -0700 (PDT)
In-Reply-To: <m1aapcejf5.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 22:53, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Kay Sievers <kay.sievers@vrfy.org> writes:

>> It should only be used if it's really needed for known used userspac=
e
>> interfaces. A few others that got converted already did not need it.
>
> Interesting. =C2=A0The symlink creation is slightly buggy in that it =
is
> created after the uevent for device creation has been sent. =C2=A0Whi=
ch can
> lead to some interesting races in userspace.

At uevent time the 'subsystem' is specified by the 'sybsystem' link
and the SUBSYSTEM property in the event environment. The device should
not really rely on finding itself linked in class. The class and bus
link collections are only to find a group of devices of the same
subsystem, and this should not be a real world problem here.

Also there are plans to merge struct class and struct bus_type
completely and keep only a few flags around where stuff should show up
for compatibility. At that point all stuff will be created at the same
time.

> As for the rest the bus compat code is similar but not quite the same
> as the class code, so I would be extremely reluctant to deploy it
> except in extremely limited cases. =C2=A0Backwards compatibility is
> important, and we should strive our best to maintain backwards
> compatibility it for the kernel<->userspace ABIs.

Today, the only real difference between class and bus devices are
these 'collection links', the devices otherwise look completely the
same. There should be no important difference.

Buses are very much preferred over classes today, no new stuff should
create any class. The bus directories are extendable and have a
reasonable layout with the devices/ subdirectory, unlike the flat
class directories where people got the silly idea to mix devices lists
with attributes to confuse everything.

Kay
