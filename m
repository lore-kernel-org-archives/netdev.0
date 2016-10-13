From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 09:34:41 +0000
Message-ID: <BY2PR07MB2309D9E2BEBC5A2091AC79E98DDC0@BY2PR07MB2309.namprd07.prod.outlook.com>
References: <20161012103340.978726-1-arnd@arndb.de>
 <BL2PR07MB23069C99213F4E89A7DC162A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <6935319.6Adbod0g1H@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6935319.6Adbod0g1H@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > > -		if (cond)
> > > +		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) && cond)
> > >			qed_rdma_dpm_bar(p_hwfn, p_ptt);
> >
> > Why not simply fix the qed_roce.h empty implementation?
>=20
> Mainly for consistency: we have a couple of interfaces that are called fr=
om the
> qed driver that are implemented in qed_roce.c. We can either use a 'stati=
c inline'
> helper for all of them, or use if(IS_ENABLED()) everywhere. Since this wa=
s the
> only function that had a helper and that helper was defined incorrectly, =
I went
> with the second option.

Actually, that's not the case. I think with this exception, all the rest of=
 the prototypes
in qed_roce.h aren't really needed, as those functions should only be acces=
sed via
the qed_rdma_ops. I'll remove those later [or we can remove them as part of=
 v2].

The genereal qed* preference is to have empty static-inline implementations
in case content is compiled-out [Look at iov for example].

> > > -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> > > +	if (!IS_ENABLED(CONFIG_INFINIBAND_QEDR))
> > > +		return 0;
> > > +
> > >  	num_l2_queues =3D 0;
> > >  	for_each_hwfn(cdev, i)
> > >  		num_l2_queues +=3D FEAT_NUM(&cdev->hwfns[i],
> QED_PF_L2_QUE); @@
> > > -738,7 +736,6 @@ static int qed_slowpath_setup_int(struct qed_dev
> > > *cdev,
> > >  	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=3D%d
> > > roce_msix_base=3D%d\n",
> > >  		   cdev->int_params.rdma_msix_cnt,
> > >  		   cdev->int_params.rdma_msix_base); -#endif
> >
> > While I don't mind, you could have argued is that we're not removing
> > enough, not too much.
> > I.e., perhaps the rdma_msix_* fields should also have been ifdef-ed
> > instead. [in which case this solution would not have worked]
>=20
> That would add even more #ifdefs though.

I agree. Although I'm never clear on the guidelines for the tradeoff -=20
How much memory/code is considered too much so that you'd have
To ifdef code out instead of 'wasting'?
[I obviously don't claim 64 bytes of memory hit that threshold]
=20
BTW, are you interested in doing a v2 for this? Or would you prefer
if we'd pick it up from here?

Thanks,
Yuval=20
