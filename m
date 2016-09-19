From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 03/11] Add support for RoCE HW init
Date: Mon, 19 Sep 2016 08:45:50 +0000
Message-ID: <SN1PR07MB220779C6959D793C5D1B7223F8F40@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-4-git-send-email-Ram.Amrani@qlogic.com>
 <29e0d88d-63f2-2b30-2856-a0e94cf31f8e@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > +	dev->max_sge =3D min_t(u32, RDMA_MAX_SGE_PER_SQ_WQE,
> > > +			     RDMA_MAX_SGE_PER_RQ_WQE);
> >
> > Our kernel target mode consumers sort of rely on max_sge_rd, you need
> > to make sure to set it too.
> Good catch. Thanks!

Actually, as I come to code this, I just realized that max_sge_rd is alread=
y set in the  query verb itself:

+int qedr_query_device(struct ib_device *ibdev,
+                     struct ib_device_attr *attr, struct ib_udata *udata)
+{

<snip>

+       attr->max_sge =3D qattr->max_sge;
+       attr->max_sge_rd =3D qattr->max_sge;

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
