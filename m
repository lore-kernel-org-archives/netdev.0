From: Toshiharu Harada <haradats@nttdata.co.jp>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 09 Apr 2008 17:37:38 +0900
Message-ID: <47FC8052.9070409@nttdata.co.jp>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms0.nttdata.co.jp ([163.135.193.231]:56126 "EHLO
	ms0.nttdata.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbYDIJeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 05:34:17 -0400
In-Reply-To: <200804071140.59247.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/8/2008 12:40 AM, Paul Moore wrote:
> On Friday 04 April 2008 8:23:12 am Tetsuo Handa wrote:
>> This file contains modifications against kernel source code
>> needed to use TOMOYO Linux 1.6.
>>
>> Although LSM hooks are provided for performing access control,
>> TOMOYO Linux 1.6 doesn't use LSM because of the following reasons.
>=20
> Hello,
>=20
> I understand your frustration with the existing LSM hooks/API and you=
r=20
> reasoning for abandoning LSM in favor of a new set of hooks, however,=
 I=20
> think this sets a dangerous precedence which could result in an=20
> abundance of security related hooks scattered throughout the kernel. =
 I=20
> would much rather see the LSM API extended/tweaked to support the nee=
ds=20
> of SAKURA and TOMOYO than ignored and duplicated; I suspect several=20
> others will say the same.
>=20
> You have made good progress with TOMOYO so far and if I can remember=20
> correctly you really only have one hurdle left, the VFS portion. =20
> Please continue to seek a solution to this that fits within the LSM=20
> framework.
>=20
> Thank you.

Thank you for your comments and concern.

I realized that we should have included the reason why we decided to
post non-LSM version. Let me explain the reason and the history.

We started developing TOMOYO Linux as original patch sets against
2.4 vanilla kernel. We understand the role of LSM, so we ported
TOMOYO Linux to use LSM and submitted it to the LKML on 13 June 2007.
We kept working to reflect feedbacks from the community and believe
no critical Nack remains.

http://lwn.net/Articles/238049/
http://lwn.net/Articles/246930/
http://lwn.net/Articles/252652/
http://lwn.net/Articles/254503/
http://lwn.net/Articles/258905/
http://lwn.net/Articles/263179/
http://lwn.net/Articles/264187/
http://lwn.net/Articles/276603/

Still there remains an issue of LSM limitation (vfsmount parameter
isn=92t passed to LSM).

LWN article 239962 says, "At the 2006 summit, Linus took a clear
position that the use of pathnames for security policies seemed
reasonable to him". Current LSM implementation is sufficient for SELinu=
x
and other label based MACs but not for pathname-based MACs.
This has been argued in the AppAmor thread for quite a long time.
Though proposals had been posted by AppArmor and TOMOYO Linux project,
none has been merged until now.

We apologize for the confusion we caused in the last posting,
but we don't want to give up returning our work to the mainline.=20

We cordially request LSM changes to pass vfsmount parameters.

=46inally, the following links are our answers to the Linux Weather For=
ecast. (http://www.linux-foundation.org/en/Linux_Weather_Forecast/secur=
ity#TOMOYO_Linux)

http://tomoyo.sourceforge.jp/wiki-e/?WhatIs#comparison
http://sourceforge.jp/projects/tomoyo/document/fosdem2008.pdf
http://sourceforge.jp/projects/tomoyo/document/PacSec2007-handout.pdf

Regards,
Toshiharu Harada
NTT DATA CORPORATION

