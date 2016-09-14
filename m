From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [RFC 08/11] Add support for data path
Date: Wed, 14 Sep 2016 10:16:50 +0000
Message-ID: <SN1PR07MB220730C60A781B9069934AD6F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-9-git-send-email-Ram.Amrani@qlogic.com>
 <40a9df9e-a0aa-9020-c523-6042baf729d1@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Michal.Kalderon@qlogic.com" <Michal.Kalderon@qlogic.com>,
        "rajesh.borundia@qlogic.com" <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0049.outbound.protection.outlook.com ([104.47.40.49]:60672
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750975AbcINKQw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 06:16:52 -0400
In-Reply-To: <40a9df9e-a0aa-9020-c523-6042baf729d1@grimberg.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +	pbe =3D (struct regpair *)pbl_table->va;
> > +	num_pbes =3D 0;
> > +
> > +	for (i =3D 0; i < mr->npages &&
> > +	     (total_num_pbes !=3D mr->info.pbl_info.num_pbes); i++) {
> > +		u64 buf_addr =3D mr->pages[i];
> > +
> > +		pbe->lo =3D cpu_to_le32((u32)buf_addr);
> > +		pbe->hi =3D cpu_to_le32((u32)upper_32_bits(buf_addr));
>=20
> Thats a shame... you could have easily set the buf_addr correctly in
> qedr_set_page...
>=20
> I think you could have also set the pbe directly from set_page if you hav=
e access
> to pbl_table from your mr context (and if I understand correctly I think =
you do,
> mr->info.pbl_table)...
I see what you mean, we can surely improve here and will. Thanks.
