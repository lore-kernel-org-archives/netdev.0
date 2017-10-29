From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: Re: [PATCH net-next] qed: Set error code for allocation failures
Date: Sun, 29 Oct 2017 07:45:23 +0000
Message-ID: <CY1PR0701MB2012AE5C7622691629FDDB9488580@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <20171027064020.aq52ue4kfp5htrb5@mwanda>
 <9ae1759e-18a1-18fb-ec93-8edf947b1cc6@huawei.com>,<20171027115252.hhqc2u6zrn5b4uet@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20171027115252.hhqc2u6zrn5b4uet@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Sent: Friday, October 27, 2017 2:52 PM

>On Fri, Oct 27, 2017 at 05:32:42PM +0800, Yunsheng Lin wrote:
>> >     iwarp_info =3D &p_hwfn->p_rdma_info->iwarp;
>> > @@ -2696,6 +2696,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>> >     if (rc)
>> >             goto err;
>> >
>> > +   rc =3D -ENOMEM;
>> >     iwarp_info->partial_fpdus =3D kcalloc((u16)p_hwfn->p_rdma_info->nu=
m_qps,
>> >                                         sizeof(*iwarp_info->partial_fp=
dus),
>> >                                         GFP_KERNEL);
>>
>> Does the memory allocated here need to be freed when error happens below=
?
>>
>
>Hm...  I think you're right that it leaks.  Also I'm confused by the
>qed_iwarp_ll2_alloc_buffers() allocation.  The comment in there says
>that /* buffers will be deallocated by qed_ll2 */ but qed_ll2 is not
>a function name or something which is useful to grep.

Thanks Dan, partial_fpdus is released during qed_iwarp_resc_free, called fr=
om qed_rdma_resc_free
called on qed_rdma_stop and on failure during qed_rdma_start.
Regarding ll2 buffers. For each successfully allocated buffer we call
qed_iwarp_ll2_post_rx->qed_ll2_post_rx_buffer.
These buffers will get released and freed when we call qed_ll2_terminate_co=
nnection
called from qed_iwarp_ll2_stop ( which is called during qed_iwarp_ll2_start=
 on error ).
thanks,
Michal=20

