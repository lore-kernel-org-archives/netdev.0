From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Tue, 15 Nov 2011 21:02:24 +0100
Message-ID: <4EC2C550.6050805@gmail.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com> <20111115193535.GC25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52844 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077Ab1KOUCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 15:02:25 -0500
Received: by wwe5 with SMTP id 5so6694110wwe.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 12:02:24 -0800 (PST)
In-Reply-To: <20111115193535.GC25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/11/2011 20:35, Andy Gospodarek a =E9crit :
> On Tue, Nov 15, 2011 at 08:24:29PM +0100, Nicolas de Peslo=FCan wrote=
:
>> Le 15/11/2011 18:00, Andy Gospodarek a =E9crit :
>>> On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
>>>> When changing mode via bonding's sysfs, the slaves are not initial=
ized
>>>> correctly. Forbid to change modes with slaves present to ensure th=
at every
>>>> slave is initialized correctly via bond_enslave().
>>>>
>>>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>>>
>>> Looks good.  This behavior forces someone who wants to change to mo=
de to
>>> go through steps that are almost as destructive as when module opti=
ons
>>> are used to configure the mode.  I do not see a problem with this.
>>
>> Except the fact that is enforce one more constraint on the exact ord=
er
>> one should write into sysfs to setup a bonding interface. We already=
 have
>> many such constraints and probably don't need more.
>>
>> Currently, it is possible to enslave slaves before selecting the mod=
e.
>> The ifenslave-2.6 package from Debian currently enslave slaves befor=
e
>> setting the mode and would break with this change.
>>
>
> Our testing indicates that 802.3ad mode bonding will not work unless =
the
> devices are enslaved after the mode is set.  Does this mean that no o=
ne
> using Debian is using 802.2ad mode or are they just not reporting it?

I don't know. Possibly, they setup the bonding by hand, instead of rely=
ing on the bonding extensions=20
of /etc/network/interfaces provided by the ifenslave-2.6 package.

Having a look at popularity for the package (http://qa.debian.org/popco=
n.php?package=3Difenslave-2.6),=20
it is obviously not the most popular one, but...

To try and fix the problem you noticed, if might be desirable to assert=
 carrier off then on for all=20
slaves when entering 802.3ad mode.

	Nicolas
