From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCHv3] netns: oops in ip[6]_frag_reasm incrementing stats
Date: Tue, 17 Mar 2009 14:54:04 +0100
Message-ID: <49BFAB7C.1020503@dti2.net>
References: <49BA87F4.1090709@dti2.net> <49BA8B65.2060408@dti2.net> <49BE4192.7090706@dti2.net> <49BEBF25.70008@gmail.com> <49BECA4A.4080207@dti2.net> <20090316224645.GA3129@ami.dom.local> <49BF8FBE.7010800@dti2.net> <20090317132113.GA6939@ff.dom.local>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:4969 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbZCQNyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 09:54:10 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50002694223.msg
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 14:54:07 +0100
In-Reply-To: <20090317132113.GA6939@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski escribi=F3:
> On Tue, Mar 17, 2009 at 12:55:42PM +0100, Jorge Boncompte [DTI2] wrot=
e:
>> dev can be NULL in ip[6]_frag_reasm for skb's coming from RAW socket=
s.
>>
>> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfil=
ter
>> conntrack reassembles them on the OUTPUT path you hit this code path=
=2E
>>
>> You can test it with something like "hping2 -0 -d 2000 -f AA.BB.CC.D=
D"
>>
>> Changes from v2: (address comments from Jarek Poplawski)
>> 	- Patch reworked to get the net pointer with container_of()
>> 	  instead of passing it to function calls.
>> 	- Fix IPv6 code
>> Changes from v1:
>> 	- Fixed description
>=20
> I guess David will be interested only with the final state of changes=
,
> so v1 & v2 are not necessary here...
>=20
> Anyway, ipv4 looks OK to me, but ipv6 looks like something is
> different:
>> +	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
>=20
> It still depends on dev !=3D NULL in __in6_dev_get(). I see there
> is also used skb->dst for similar things in ip6_frag_queue(), so I
> don't know: it needs rethinking, and maybe these patches should be
> separated if you prefer.

	Not my day! :-) I should not look at code at 2 am and write patches
the day after, I confused _idev and idev in the check for !=3D NULL in =
_DEVINC.

	I think this bug was first introduced by patch "[IPV6]: Per-interface
statistics support." from YOSHIFUJI Hideaki on Nov 4, 2006.

	If someone with more knowledge could confirm that using something like=
=2E..

"(skb->dev ? skb->dev : skb->dst->dev)"

=2E.. here is fine I'll redo this part and resend. I do not have an IPv=
6 setup where
I can test this.

	Regards,

	Jorge
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- Sin pistachos no hay Rock & Roll...
- Without wicker a basket cannot be made.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

