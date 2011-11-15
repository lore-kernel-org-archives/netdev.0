From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Tue, 15 Nov 2011 20:24:29 +0100
Message-ID: <4EC2BC6D.9000304@gmail.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33602 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1KOTYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 14:24:30 -0500
Received: by wwe5 with SMTP id 5so6641609wwe.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 11:24:29 -0800 (PST)
In-Reply-To: <20111115170018.GB25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/11/2011 18:00, Andy Gospodarek a =E9crit :
> On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
>> When changing mode via bonding's sysfs, the slaves are not initializ=
ed
>> correctly. Forbid to change modes with slaves present to ensure that=
 every
>> slave is initialized correctly via bond_enslave().
>>
>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>
> Looks good.  This behavior forces someone who wants to change to mode=
 to
> go through steps that are almost as destructive as when module option=
s
> are used to configure the mode.  I do not see a problem with this.

Except the fact that is enforce one more constraint on the exact order =
one should write into sysfs=20
to setup a bonding interface. We already have many such constraints and=
 probably don't need more.

Currently, it is possible to enslave slaves before selecting the mode. =
The ifenslave-2.6 package=20
from Debian currently enslave slaves before setting the mode and would =
break with this change.

NAK.

	Nicolas.
