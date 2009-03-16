From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCHv2] netns: oops in ip_frag_reasm incrementing stats
Date: Mon, 16 Mar 2009 22:53:14 +0100
Message-ID: <49BECA4A.4080207@dti2.net>
References: <49BA87F4.1090709@dti2.net> <49BA8B65.2060408@dti2.net> <49BE4192.7090706@dti2.net> <49BEBF25.70008@gmail.com>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:3167 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759071AbZCPVxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 17:53:23 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50002681241.msg
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 22:53:18 +0100
In-Reply-To: <49BEBF25.70008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski escribi=F3:
> Jorge Boncompte [DTI2] wrote, On 03/16/2009 01:09 PM:
>=20
>> dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.
>>
>> Quagga's OSPFD sends fragmented packets on a RAW socket, when netfil=
ter
>> conntrack reassembles them on the OUTPUT path you hit this code path=
=2E
>>
>> Changes from v1:
>>    - Fixed description
>>
>> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>> ---
>> net/ipv4/ip_fragment.c |   14 +++++++-------
>> 1 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
>> index 6659ac0..8f150d5 100644
>> --- a/net/ipv4/ip_fragment.c
>> +++ b/net/ipv4/ip_fragment.c
>=20
> ...
>=20
>> -static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
>> +static int ip_frag_reasm(struct net *net, struct ipq *qp, struct sk=
_buff *prev,
>> 			 struct net_device *dev)
>> {
>> 	struct iphdr *iph;
>> @@ -548,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct =
sk_buff *prev,
>> 	iph =3D ip_hdr(head);
>> 	iph->frag_off =3D 0;
>> 	iph->tot_len =3D htons(len);
>> -	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
>> +	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
>=20
>=20
> I didn't check this but isn't something like this possible here too?:
>=20
> static inline int ip_frag_too_far(struct ipq *qp)
> {
> 	...
>         net =3D container_of(qp->q.net, struct net, ipv4.frags);
>         IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
>=20

	Yes, it seems so. I did not noticed how the rest of the code accessed
the net pointer, sorry.
	Do you want to send a patch yourself or should I do it?

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

