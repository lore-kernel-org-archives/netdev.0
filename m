From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding and ifenslave version.
Date: Wed, 03 Aug 2011 13:07:57 -0700
Message-ID: <1718.1312402077@death>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr> <4E38EE23.8030703@gmail.com> <CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com> <4E39A3A7.1080905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:45801 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867Ab1HCUIC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 16:08:02 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p73CUqsN016157
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 06:30:52 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p73K7xkT174552
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 14:07:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p73K7xUL031584
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 14:07:59 -0600
In-reply-to: <4E39A3A7.1080905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 03/08/2011 21:03, Andy Gospodarek a =C3=A9crit :
>
>>> I thought introducing a new option should cause the driver version =
to
>>> change. Am I right?
>>
>> When a significant change happens, we try to change the version
>> number.  The version number probably should have been changed when
>> those were added.  Inspecting the module options or sysfs parameters
>> indicate whether or not these patches were added, so it is less of a
>> priority than when some internal infrastructure (like moving to use
>> rx_handler) changes.
>>
>> I consider it more critical to change the bonding module version whe=
n
>> something changes that cannot be detected by inspecting the module o=
r
>> sysfs parameters.  This is more helpful to users reporting problems.
>>
>
>Ok, 'sounds perfectly sensible to me, thanks.
>
>>> On a different but related topic, the version in
>>> Documentation/networking/ifenslave.c (1.1.0) didn't change since th=
e git
>>> origin and probably since 2003.
>>>
>>> Arguably, none of the commit regarding this file introduced a signi=
ficant
>>> change (with the possible exception of commit
>>> e6d184e33109010412ad1d59719af74755a935f4, [NET]: Fix ifenslave to n=
ot fail
>>> on lack of IP information). But if we never change a 3-level versio=
n number,
>>> whatever the level of change, this version number might be useless.=
 Any
>>> comment?
>>>
>>>         Nicolas.
>>>
>>
>> Distributions benefit from version numbers on userspace utils.  It
>> would probably be better to keep ifenslave's version number as it is
>> to help those maintaining those distro packages.
>
>As one of the maintainers for the ifenslave package on Debian, I perfe=
ctly
>understand the need for an upstream version, but as such, I expected t=
he
>upstream version number to change when the file change... Version numb=
ers
>in Debian use upstream version numbers when available and add a subver=
sion
>number for Debian specific changes. I would expect to change the versi=
on
>number and not only the Debian subversion when the only change is a ne=
w
>upstream version.

	One thing to remember here is that currently very few (perhaps
no) distros use the ifenslave.c that comes with mainline.  The distros
I'm familiar with configure bonding via sysfs, either directly in
initscripts / sysconfig, or via a shell script ifenslave (which I
believe is what Debian has).  Many distros still install it in
/sbin/ifenslave, but it isn't used by the network configuration stuff.

	The ifenslave.c in mainline is pretty much just a legacy for
backwards compatibility; it has not had a bug fix since 2005 (a few typ=
o
repairs since then), and no major functional changes since before the
git era.

	I was considering proposing feature removal for ifenslave.c and
the ioctl API to add and remove slaves, but some discussion a few month=
s
ago indicated that there are apparently still some users out there (I'd
guess embedded of some variety).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
