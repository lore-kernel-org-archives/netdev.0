From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v10 04/22] IB/hns: Add RoCE engine reset function
Date: Tue, 28 Jun 2016 11:09:26 +0300
Message-ID: <20160628080926.GC3584@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-5-git-send-email-oulijun@huawei.com>
 <20160624145938.GE23995@leon.nu>
 <576E5C21.5030904@huawei.com>
 <20160627080122.GA3584@leon.nu>
 <5770E465.1070702@huawei.com>
 <577219CD.2000604@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bAmEntskrkuBymla"
Cc: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <577219CD.2000604-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--bAmEntskrkuBymla
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 28, 2016 at 02:31:41PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/27 16:31, oulijun wrote:
> >Hi, Leon
> >=E5=9C=A8 2016/6/27 16:01, Leon Romanovsky =E5=86=99=E9=81=93:
> >>On Sat, Jun 25, 2016 at 06:25:37PM +0800, Wei Hu (Xavier) wrote:
> >>>
> >>>On 2016/6/24 22:59, Leon Romanovsky wrote:
> >>>>On Thu, Jun 16, 2016 at 10:35:12PM +0800, Lijun Ou wrote:
> >>>>>This patch mainly added reset flow of RoCE engine in RoCE
> >>>>>driver. It is necessary when RoCE is loaded and removed.
> >>>>>
> >>>>>Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> >>>>>Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >>>>>---
> >>...
> >>
> >>>>>+
> >>>>>+#define SLEEP_TIME_INTERVAL				20
> >>>>>+
> >>>>>+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, b=
ool enable);
> >>>>Why did you add this extern?
> >>>>You already exported this function.
> >>>>drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:EXPORT_SYMBOL(hns_=
dsaf_roce_reset);
> >>>Hi, Leon
> >>>
> >>>         The function named hns_dsaf_roce_reset is defined in hns_dsaf=
_main.c
> >>>         It exists in hns_dsaf.ko(ethernet driver)
> >>>
> >>>         RoCE driver will call this function.
> >>>
> >>>         Your suggestion is that delete "extern" as below:
> >>>             In /drivers/infiniband/hw/hns/hns_roce_hw_v1.h:
> >>>
> >>>           int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, =
bool
> >>>enable);
> >>>
> >>>Right? or other soultion?
> >>You placed it in header file.
> >>Please move it to your hns_roce_hw_v1.c file.
> >>
> >  You suggest to do as follows, right?
> >  in hns_roce_hw_v1.c
> >    int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enab=
le);
> >
> >  and delete the keyword extern
> >
> >  Bcause reserve the extern in hns_roce_hw_v1.c, the checkpatch is not p=
ass.
> Hi, Leon & Doug Ledford
>=20
>     If we move it to hns_roce_hw_v1.c file as below:
>         int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool
> enable);
>     The result of checkpatch is warning.
>=20
>     We prepare to add a head file for this function as below:
>         In the directory of include\linux,  mkdir hns.
>         add hns_driver.h in include\linux\hns.
>         In the file of hns_driver.h, the declaration:
>                int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode,
> bool enable);
>     What do you think about?
>=20
>

Please avoid creating new directories/files under include/linux,
especially for one function only.

--bAmEntskrkuBymla
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXcjC2AAoJEORje4g2clinH0QP/is5TiAbbRkxaCyEcPTwcmGA
vzswCNyDSrx8DPz+jJMEOQXBGl+xdELYnJeIiRLGre9wXGxBp010Cei89OWUljtY
SD0EuGglo9v7Ru1uNNbZKYIXHm6DRYWUI2jTSejeFh/RmilkKG27x5mtPgTqoxn9
Ut/XOvFUbX36G30EL0hFl0KLYIlKdDWxhkVvtEqgW/Ej972KB2iUvPM6icvGQSa/
ERxfKXhPKTHleX5wsdTrVG3c5w2qUggSdnpTL0YE3FpQybPczvX4kTj28xhlH2x1
kiv/Xsyb+hy8H0KZkH/zEjIea4UpoWX3ve+ExI4DP3Tv3ex4ykYyo2Thw0OMwLXv
5Vy+zMMMT7aKZmVZhR5yiWpQSvrwGk6/QN/5N79RX0HcnXqzplZN9VYIrIOXqyjA
Cifwo4vTbdKJj4M8qZqU+pUmfoPIWy0pqExy1GRVbUneNp3Pg7Ifuost7JZZN0Pt
IIRGuBhn9hE0GO0qLce14ir3xzIICJrckeauCN4CmxpRoJClYpJbct9nTzJSuZn4
wkAuZ42M1DkHAk3uMLc70Oa5nJBKxyoTJgOgdUf2o5AKX+53sxdLuQlAYyx45BqX
F+BmdQAqJe8Y/Dqw4mEgj0BkBkvWBoapTmGX3+s4Bf/RVbZXsZltvIAD2YUKMYei
scEeZS7xmboZHJgKzj0z
=gAna
-----END PGP SIGNATURE-----

--bAmEntskrkuBymla--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
