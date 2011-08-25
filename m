From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 10:44:30 +0200
Message-ID: <8FCB5B33-20EA-470D-96CB-0565FABAD03A@comsys.rwth-aachen.de>
References: <1314226834.6797.5.camel@edumazet-laptop>
 <1314229310-8074-1-git-send-email-hagen@jauu.net>
 <CAK6E8=dXf=wsZOB+ZUNuUpLyV2vrcgf7pvwYPz1YTmF81WuGDA@mail.gmail.com>
 <1314250134.6797.24.camel@edumazet-laptop>
 <4033BFEE-C432-4D94-8372-BA166AF2AA26@comsys.rwth-aachen.de>
 <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>,
	Hannemann Arnd <arnd@arndnet.de>,
	Lukowski Damian <damian@tvk.rwth-aachen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:59041 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752037Ab1HYIod convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 04:44:33 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LQH00COL6Y8KUJ0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 25 Aug 2011 10:44:32 +0200 (CEST)
Received: from [192.168.4.12] ([unknown] [77.109.115.129])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LQH00FOV6Y64L20@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 25 Aug 2011 10:44:32 +0200 (CEST)
In-reply-to: <1314260805.2387.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 25.08.2011 um 10:26 schrieb Eric Dumazet:

> Le jeudi 25 ao=FBt 2011 =E0 09:28 +0200, Alexander Zimmermann a =E9cr=
it :
>> Hi Eric,
>>=20
>> Am 25.08.2011 um 07:28 schrieb Eric Dumazet:
>=20
>>> Real question is : do we really want to process ~1000 timer interru=
pts
>>> per tcp session, ~2000 skb alloc/free/build/handling, possibly ~100=
0 ARP
>>> requests, only to make tcp revover in ~1sec when connectivity retur=
ns
>>> back. This just doesnt scale.
>>=20
>> maybe a stupid question, but 1000?. With an minRTO of 200ms and a ma=
ximum
>> probing time of 120s, we 600 retransmits in a worst-case-senario
>> (assumed that we get for every rot retransmission an icmp). No?
>=20
> Where is asserted the "max probing time of 120s" ?=20
>=20
> It is not the case on my machine :
> I have way more retransmits than that, even if spaced by 1600 ms
>=20
> 07:16:13.389331 write(3, "\350F\235JC\357\376\363&\3\374\270R\21L\26\=
324{\37p\342\244i\304\356\241I:\301\332\222\26"..., 48) =3D 48
> 07:16:13.389417 select(7, [3 4], [], NULL, NULL) =3D 1 (in [3])
> 07:31:39.901311 read(3, 0xff8c4c90, 8192) =3D -1 EHOSTUNREACH (No rou=
te to host)
>=20
> Old kernels where performing up to 15 retries, doing exponential back=
off.

Yes I know. And in combination with RFC6069 we have to convert this
See Section 7.1

and

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D6fa12c85031485dff38ce550c24f10da23b0adaa

Is the transformation broken? Damian?


>=20
> Now its kind of unlimited, according to experimental results.

Ok, unlimited is not what I expect...


>=20
>=20
>=20

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//
