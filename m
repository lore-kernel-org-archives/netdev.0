From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
	present
Date: Tue, 15 Nov 2011 14:35:39 -0500
Message-ID: <20111115193535.GC25132@gospo.rdu.redhat.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757212Ab1KOTfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 14:35:44 -0500
Content-Disposition: inline
In-Reply-To: <4EC2BC6D.9000304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 08:24:29PM +0100, Nicolas de Peslo=FCan wrote:
> Le 15/11/2011 18:00, Andy Gospodarek a =E9crit :
>> On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
>>> When changing mode via bonding's sysfs, the slaves are not initiali=
zed
>>> correctly. Forbid to change modes with slaves present to ensure tha=
t every
>>> slave is initialized correctly via bond_enslave().
>>>
>>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>>
>> Looks good.  This behavior forces someone who wants to change to mod=
e to
>> go through steps that are almost as destructive as when module optio=
ns
>> are used to configure the mode.  I do not see a problem with this.
>
> Except the fact that is enforce one more constraint on the exact orde=
r=20
> one should write into sysfs to setup a bonding interface. We already =
have=20
> many such constraints and probably don't need more.
>
> Currently, it is possible to enslave slaves before selecting the mode=
=2E=20
> The ifenslave-2.6 package from Debian currently enslave slaves before=
=20
> setting the mode and would break with this change.
>

Our testing indicates that 802.3ad mode bonding will not work unless th=
e
devices are enslaved after the mode is set.  Does this mean that no one
using Debian is using 802.2ad mode or are they just not reporting it?
