From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Wed, 22 Dec 2010 14:43:50 +0100
Message-ID: <4D120096.6080508@6wind.com>
References: <4CA208C9.1020800@6wind.com>	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>	 <1285749349.2615.27.camel@edumazet-laptop>	 <1285751929.2615.30.camel@edumazet-laptop>  <4D11B7AC.8000205@6wind.com>	 <1293011708.3027.28.camel@edumazet-laptop> <1293012464.3027.30.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36967 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab0LVNn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 08:43:56 -0500
Received: by wwa36 with SMTP id 36so5288163wwa.1
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 05:43:55 -0800 (PST)
In-Reply-To: <1293012464.3027.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I saw this commit, but I still got the problem:

shelby:/home/root/src# uname -a
Linux shelby 2.6.37-rc5+ #10 SMP Wed Dec 22 05:02:53 EST 2010 i686 GNU/=
Linux
shelby:/home/root/src# ip tunnel add mode ipip remote 10.16.0.164 local=
=20
10.16.0.72 dev eth0
shelby:/home/root/src# ./a.out tunl1
shelby:/home/root/src# ip tunnel del tunl1

Message from syslogd@shelby at Dec 22 10:12:08 ...
  kernel:[18459.828011] unregister_netdevice: waiting for tunl1 to beco=
me free.=20
Usage count =3D 3

Message from syslogd@shelby at Dec 22 10:12:19 ...
  kernel:[18470.072017] unregister_netdevice: waiting for tunl1 to beco=
me free.=20
Usage count =3D 3

Message from syslogd@shelby at Dec 22 10:12:29 ...
  kernel:[18480.316011] unregister_netdevice: waiting for tunl1 to beco=
me free.=20
Usage count =3D 3

Message from syslogd@shelby at Dec 22 10:12:39 ...
  kernel:[18490.560010] unregister_netdevice: waiting for tunl1 to beco=
me free.=20
Usage count =3D 3
shelby:/home/root/src#

I don't know if I will have time to investigate more before next year.

Regards,
Nicolas


Le 22.12.2010 11:07, Eric Dumazet a =C3=A9crit :
> Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 10:55 +0100, Eric Dumazet a =
=C3=A9crit :
>> Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 09:32 +0100, Nicolas Dichte=
l a =C3=A9crit :
>>> What is the status of this patch? The initial problem is still here=
 in 2.6.37-rc5+
>>>
>> I cannot reproduce the problem on net-next-2.6, are you sure we stil=
l
>> need a new patch ?
>>
>> # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev et=
h0
>> # ip link show dev tunl1
>> 19: tunl1: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN=20
>>     link/ipip 10.16.0.72 peer 10.16.0.164
>> # /root/vrrp tunl1
>> # ip tunnel del tunl1
>>
>>
>=20
> (I thought commit 332dd96f7ac15e fixed the problem for you, as it did
> for me)
>=20
> net/dst: dst_dev_event() called after other notifiers
>=20
>=20
>=20

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 10
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
Join the Multicore Packet Processing Forum: www.multicorepacketprocessi=
ng.com

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou=20
ses destinataires. Il contient des informations confidentielles qui son=
t la=20
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations=20
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par=20
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les=20
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the=20
intended recipient(s) and contains information that is confidential and=
=20
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution=20
is prohibited. If you are not the intended recipient, please contact th=
e sender=20
by reply e-mail and destroy all copies of the original message.
