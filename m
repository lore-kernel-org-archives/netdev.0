From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: Re: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Mon, 22 Oct 2007 14:45:47 +0800
Message-ID: <471C471B.6020109@cn.fujitsu.com>
References: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:52116 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751413AbXJVGtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 02:49:24 -0400
In-Reply-To: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 =E5=86=99=E9=81=93:
> Gui Jianfeng wrote on 10/22/2007 11:37:07 AM:
>=20
>> @@ -310,8 +310,12 @@ static inline int ip_rcv_finish(struct s
>>      *   how the packet travels inside Linux networking.
>>      */
>>     if (skb->dst =3D=3D NULL) {
>> -      if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev=
))
>> -         goto drop;
>> +      int err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->=
tos,
> dev);
>> +      if (unlikely(err)) {
>> +         if (err =3D=3D -EHOSTUNREACH)
>> +            IP_INC_STATS_BH(IpInAddrErrors);
>> +      }
>> +      goto drop;
>>     }
>=20
> Shouldn't the "goto drop" be inside the "if (unlikely(err)) {" case?
yes, you are right :-)

> And normally it is nice to have a blank line after variable declarati=
on.
>=20
> - KK
>=20
>=20
>=20


--=20


Regards
Gui Jianfeng
--------------------------------------------------
Gui Jianfeng
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630566-851
COINS: 79955-851
=46AX: +86+25-83317685
MAIL:guijianfeng@cn.fujitsu.com
--------------------------------------------------
