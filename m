From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: hns: optimize XGE capability by reducing
 cpu usage
Date: Sun, 06 Dec 2015 19:32:00 -0800
Message-ID: <1449459120.7356.14.camel@perches.com>
References: <1449300749-50275-1-git-send-email-yankejian@huawei.com>
	 <20151206.222929.804694720513782203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lisheng011@huawei.com, lipeng321@huawei.com,
	salil.mehta@huawei.com, huangdaode@hisilicon.com,
	xuwei5@hisilicon.com, liguozhu@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, linuxarm@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151206.222929.804694720513782203.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-12-06 at 22:29 -0500, David Miller wrote:
> From: yankejian <yankejian@huawei.com>
> Date: Sat, 5 Dec 2015 15:32:29 +0800
>=20
> > +#if (PAGE_SIZE < 8192)
> > +=A0=A0=A0=A0=A0if (hnae_buf_size(ring) =3D=3D HNS_BUFFER_SIZE_2048=
) {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D hnae_buf_size(=
ring);
> > +=A0=A0=A0=A0=A0} else {
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D ALIGN(size, L1=
_CACHE_BYTES);
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0last_offset =3D hnae_page_s=
ize(ring) - hnae_buf_size(ring);
> > +=A0=A0=A0=A0=A0}
> > +
> > +#else
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0truesize =3D ALIGN(size, L1=
_CACHE_BYTES);
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0last_offset =3D hnae_page_s=
ize(ring) - hnae_buf_size(ring);
> > +#endif
>=20
> This is not indented properly, and it looks terrible.

And it makes one curious as to why last_offset isn't set
in the first block.
