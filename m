From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding and ifenslave version.
Date: Wed, 03 Aug 2011 22:38:03 +0200
Message-ID: <4E39B1AB.7050502@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr> <4E38EE23.8030703@gmail.com> <CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com> <4E39A3A7.1080905@gmail.com> <1718.1312402077@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49239 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab1HCUiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 16:38:06 -0400
Received: by wyf22 with SMTP id 22so100399wyf.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 13:38:05 -0700 (PDT)
In-Reply-To: <1718.1312402077@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2011 22:07, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:
>> Le 03/08/2011 21:03, Andy Gospodarek a =C3=A9crit :

>>> Distributions benefit from version numbers on userspace utils.  It
>>> would probably be better to keep ifenslave's version number as it i=
s
>>> to help those maintaining those distro packages.
>>
>> As one of the maintainers for the ifenslave package on Debian, I per=
fectly
>> understand the need for an upstream version, but as such, I expected=
 the
>> upstream version number to change when the file change... Version nu=
mbers
>> in Debian use upstream version numbers when available and add a subv=
ersion
>> number for Debian specific changes. I would expect to change the ver=
sion
>> number and not only the Debian subversion when the only change is a =
new
>> upstream version.
>
> 	One thing to remember here is that currently very few (perhaps
> no) distros use the ifenslave.c that comes with mainline.  The distro=
s
> I'm familiar with configure bonding via sysfs, either directly in
> initscripts / sysconfig, or via a shell script ifenslave (which I
> believe is what Debian has).  Many distros still install it in
> /sbin/ifenslave, but it isn't used by the network configuration stuff=
=2E

The ifenslave package on Debian provide two things:

- The binary ifenslave, simply compiled from mainline ifenslave.c.
- A plug-in for ifupdown to allow for bonding related options in /etc/n=
etwork/interfaces. I can=20
confirm that this plug-in doesn't use the ifenslave command, but sysfs,=
 since version 1.1.0-12=20
(current stable version of this package is 1.1.0-17).

> 	The ifenslave.c in mainline is pretty much just a legacy for
> backwards compatibility; it has not had a bug fix since 2005 (a few t=
ypo
> repairs since then), and no major functional changes since before the
> git era.
>
> 	I was considering proposing feature removal for ifenslave.c and
> the ioctl API to add and remove slaves, but some discussion a few mon=
ths
> ago indicated that there are apparently still some users out there (I=
'd
> guess embedded of some variety).

Unfortunately, there exist *many* how-to that suggest to use ifenslave,=
 causing many users to use it=20
instead of sysfs for bonding setup.

At least, we can:
- update the bonding documentation to clarify that ifenslave is depreca=
ted (and move most ifenslave=20
related stuffs at the end of the documentation);
- possibly issue a warning when the API is used, suggesting to use sysf=
s instead.

I can take care of the documentation update if appropriate.

	Nicolas.
