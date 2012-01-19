From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bpf_jit: fix divide by 0 generation
Date: Thu, 19 Jan 2012 09:07:44 +0100
Message-ID: <1326960464.1113.28.camel@edumazet-laptop>
References: <20120118022709.GA4167@linuxace.com>
	 <1326867428.2606.39.camel@edumazet-laptop>
	 <1326871835.2606.40.camel@edumazet-laptop>
	 <1326873533.2606.46.camel@edumazet-laptop>
	 <20120118155747.GA4991@linuxace.com>
	 <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49660 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681Ab2ASIHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 03:07:49 -0500
Received: by wics10 with SMTP id s10so149845wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 00:07:47 -0800 (PST)
In-Reply-To: <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 17:01 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mercredi 18 janvier 2012 =C3=A0 07:57 -0800, Phil Oester a =C3=A9c=
rit :
>=20
> > Got the following output after applying this fix (no panic this tim=
e):
> >=20
> > proglen=3D231 !=3D oldproglen=3D235
> > bpb_jit_compile fatal error
> >=20
> > Filter being used is 'not net a.b.x.112/28 and not net a.b.y.112/28=
'
>=20

By the way, libcap gives following code, not optimal

(000) ldh      [12]
(001) jeq      #0x800           jt 2	jf 14
(002) ld       [26]
(003) and      #0xfffffff0
(004) jeq      #0x1020340       jt 28	jf 5
(005) ld       [26]
(006) and      #0xfffffff0
(007) jeq      #0x1021480       jt 28	jf 8
(008) ld       [30]
(009) and      #0xfffffff0
(010) jeq      #0x1020340       jt 28	jf 11
(011) ld       [30]
(012) and      #0xfffffff0
(013) jeq      #0x1021480       jt 28	jf 29

=2E..

could be :

(000) ldh      [12]
(001) jeq      #0x800           jt 2	jf 10

(002) ld       [26]
(003) and      #0xfffffff0
(004) jeq      #0x1020340       jt ok	jf 5
(005) jeq      #0x1021480       jt ok	jf 6

(006) ld       [30]
(007) and      #0xfffffff0
(008) jeq      #0x1020340       jt ok	jf 9
(009) jeq      #0x1021480       jt ok	jf ret0

=2E..
