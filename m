From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: hns: optimize XGE capability by reducing
 cpu usage
Date: Mon, 07 Dec 2015 01:05:09 -0800
Message-ID: <1449479109.3597.1.camel@perches.com>
References: <1449300749-50275-1-git-send-email-yankejian@huawei.com>
	 <20151206.222929.804694720513782203.davem@davemloft.net>
	 <1449459120.7356.14.camel@perches.com> <56654A36.6090106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lisheng011@huawei.com, lipeng321@huawei.com,
	salil.mehta@huawei.com, huangdaode@hisilicon.com,
	xuwei5@hisilicon.com, liguozhu@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, linuxarm@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0114.hostedemail.com ([216.40.44.114]:50039 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753335AbbLGJFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 04:05:14 -0500
In-Reply-To: <56654A36.6090106@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-07 at 16:58 +0800, Yankejian (Hackim Yim) wrote:
> On 2015/12/7 11:32, Joe Perches wrote:
> > On Sun, 2015-12-06 at 22:29 -0500, David Miller wrote:
> > > > From: yankejian <yankejian@huawei.com>
> > > > Date: Sat, 5 Dec 2015 15:32:29 +0800
> > > >=20
> > > > > > +#if (PAGE_SIZE < 8192)
> > > > > > +=A0=A0=A0=A0=A0if (hnae_buf_size(ring) =3D=3D HNS_BUFFER_S=
IZE_2048) {
> > > > > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D hnae_b=
uf_size(ring);
> > > > > > +=A0=A0=A0=A0=A0} else {
> > > > > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D ALIGN(=
size, L1_CACHE_BYTES);
> > > > > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0last_offset =3D hna=
e_page_size(ring) - hnae_buf_size(ring);
> > > > > > +=A0=A0=A0=A0=A0}
> > > > > > +
> > > > > > +#else
> > > > > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D ALIGN(=
size, L1_CACHE_BYTES);
> > > > > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0last_offset =3D hna=
e_page_size(ring) - hnae_buf_size(ring);
> > > > > > +#endif
> > > >=20
> > > > This is not indented properly, and it looks terrible.
> > And it makes one curious as to why last_offset isn't set
> > in the first block.
>=20
> Hi Joe,

Hello.

> if hnae_buf_size que equal to HNS_BUFFER_SIZE, last_offset is useless=
 in the routines of this function.
> so it is ignored in the first block. thanks for your suggestion.

More to the point, last_offset is initialized to 0.

It'd be clearer not to initialize it at all and
set it to 0 in the first block and not overwrite
the initialization in each subsequent block.
