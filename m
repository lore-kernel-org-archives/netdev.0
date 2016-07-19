From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next v2 07/10] net/faraday: Read MAC address from chip
Date: Wed, 20 Jul 2016 09:40:07 +1000
Message-ID: <20160719234007.GA4376@gwshan>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1468579460-13768-8-git-send-email-gwshan@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6D5F4FC97F@AcuExch.aculab.com>
 <1468925873.8568.47.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	"'Gavin Shan'" <gwshan@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"joel@jms.id.au" <joel@jms.id.au>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"weixue@trustnetic.com" <weixue@trustnetic.com>,
	"yuvali@mellanox.com" <yuvali@mellanox.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54564 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752024AbcGSXkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 19:40:17 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6JNcSnn037172
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 19:40:16 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2495r9qmkk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 19:40:16 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Wed, 20 Jul 2016 09:40:13 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B46553578052
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:40:09 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6JNe9Ol22544628
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:40:09 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6JNe8Br020188
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:40:09 +1000
Content-Disposition: inline
In-Reply-To: <1468925873.8568.47.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 08:57:53PM +1000, Benjamin Herrenschmidt wrote:
>On Tue, 2016-07-19 at 10:50 +0000, David Laight wrote:
>> > +=A0=A0=A0=A0=A0if (!is_valid_ether_addr(mac)) {
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[5] =3D (m >> 8) & 0xff=
;
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[4] =3D m & 0xff;
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[3] =3D (l >> 24) & 0xf=
f;
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[2] =3D (l >> 16) & 0xf=
f;
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[1] =3D (l >>=A0 8) & 0=
xff;
>> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mac[0] =3D l & 0xff;
>> > +=A0=A0=A0=A0=A0}
>> ...
>>=20
>> That is horrid, not all byte reversed addresses will be invalid.
>
>Right, that's just a hack for a broken vendor uboot we had here, Gavin=
,
>drop that part of the patch please.
>

Sure, I'll drop it in v4 or a followup patch. v3 is being reviewed this
moment.

Thanks,
Gavin
