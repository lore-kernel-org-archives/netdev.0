From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net] qed: Fix stack corruption on probe
Date: Mon, 19 Sep 2016 13:30:19 +0000
Message-ID: <BL2PR07MB230691EA558A3B80BB0751B78DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474186483-30831-1-git-send-email-Yuval.Mintz@qlogic.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01034F3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0084.outbound.protection.outlook.com ([104.47.33.84]:62067
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756640AbcISNaW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 09:30:22 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01034F3@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > -	for (i =3D 0; i < MCP_DRV_VER_STR_SIZE - 1; i +=3D 4) {
> > -		val =3D cpu_to_be32(p_ver->name[i]);
> > +	for (i =3D 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32); i++) {
> > +		val =3D cpu_to_be32(p_ver->name[i * sizeof(u32)]);
> >  		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] =3D val;
> >  	}
>=20
> That change fails the 'sanity' test.
> It looks like it is copying a string that might by byteswapped into host =
order.
> I'm guessing that the target p_drv_version->name[] is char [].
> The cpu_to_be32() call is only correct if p_ver->name[] is 32bit.
> But you are (now) indexing it with the character offset.
> So the data copied cannot be right.

Crap. Thanks for catching this up; I'll send v2 shortly.

> I also suspect it should be be32_to_cpu().
Actually, the conversion is correct as-is - data is provided by driver at
host order and should be sent to management firmware as BE.
