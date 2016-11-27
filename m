From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 09/11] qede: Better utilize the qede_[rt]x_queue
Date: Sun, 27 Nov 2016 16:15:42 +0000
Message-ID: <BL2PR07MB23064E75618105466EAA79A68D8B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480258273-24973-10-git-send-email-Yuval.Mintz@cavium.com>
 <201611272330.xRUonBtv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: kbuild test robot <lkp@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0068.outbound.protection.outlook.com ([104.47.33.68]:24548
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751532AbcK0RtO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 12:49:14 -0500
In-Reply-To: <201611272330.xRUonBtv%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Yuval,
>=20
> [auto build test WARNING on net-next/master]
>=20
> url:    https://github.com/0day-ci/linux/commits/Yuval-Mintz/qed-Add-XDP-
> support/20161127-225956
> config: tile-allmodconfig (attached as .config)
> compiler: tilegx-linux-gcc (GCC) 4.6.2
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-
> tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=3Dtile
>=20
> All warnings (new ones prefixed by >>):
>=20
>    drivers/net/ethernet/qlogic/qede/qede_main.c: In function
> 'qede_alloc_mem_rxq':
> >> drivers/net/ethernet/qlogic/qede/qede_main.c:2960:3: warning: large
> >> integer implicitly truncated to unsigned type [-Woverflow]
>=20
> vim +2960 drivers/net/ethernet/qlogic/qede/qede_main.c
>=20
> 55482edc Manish Chopra 2016-03-04  2944  err:
> 55482edc Manish Chopra 2016-03-04  2945  	qede_free_sge_mem(edev,
> rxq);
> 55482edc Manish Chopra 2016-03-04  2946  	edev->gro_disable =3D 1;
> 55482edc Manish Chopra 2016-03-04  2947  	return -ENOMEM;
> 55482edc Manish Chopra 2016-03-04  2948  } 55482edc Manish Chopra 2016-
> 03-04  2949
> 2950219d Yuval Mintz   2015-10-26  2950  /* This function allocates all
> memory needed per Rx queue */
> 1a635e48 Yuval Mintz   2016-08-15  2951  static int
> qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
> 2950219d Yuval Mintz   2015-10-26  2952  {
> f86af2df Manish Chopra 2016-04-20  2953  	int i, rc, size;
> 2950219d Yuval Mintz   2015-10-26  2954
> 2950219d Yuval Mintz   2015-10-26  2955  	rxq->num_rx_buffers =3D edev-
> >q_num_rx_buffers;
> 2950219d Yuval Mintz   2015-10-26  2956
> 1a635e48 Yuval Mintz   2016-08-15  2957  	rxq->rx_buf_size =3D
> NET_IP_ALIGN + ETH_OVERHEAD + edev->ndev->mtu;
> 1a635e48 Yuval Mintz   2016-08-15  2958
> fc48b7a6 Yuval Mintz   2016-02-15  2959  	if (rxq->rx_buf_size >
> PAGE_SIZE)
> fc48b7a6 Yuval Mintz   2016-02-15 @2960  		rxq->rx_buf_size =3D
> PAGE_SIZE;

I'd say this is a false positive, given that MTU can't be so large.
Although patch #10 is going to hit the same when setting rx_buf_seg_size
[also a u16] to PAGE_SIZE to make sure there's a single packet per page.

While I can surely address that, I was just wondering about whether this
is an interesting scenario at the moment. I.e., using XDP with 64 Kb pages
is going to be very costly from a memory perspective.
