From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support
 (fwd)
Date: Fri, 30 Jun 2017 06:51:09 +0000
Message-ID: <CY4PR12MB14321820E8A81AEDBFDACD2DC1D30@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <alpine.DEB.2.20.1706292227380.2995@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Venkatesh Pottem <venkatesh@chelsio.com>,
        "kbuild-all@01.org" <kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>,
        Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0106.outbound.protection.outlook.com ([104.47.32.106]:39872
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751651AbdF3GvM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 02:51:12 -0400
In-Reply-To: <alpine.DEB.2.20.1706292227380.2995@hadrien>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes unlock missing in couple of places, Thanks Julia.

Ganesh





From: Julia Lawall <julia.lawall@lip6.fr>
Sent: Friday, June 30, 2017 9:59 AM
To: Atul Gupta
Cc: netdev@vger.kernel.org; davem@davemloft.net; Venkatesh Pottem; Ganesh G=
R; kbuild-all@01.org
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support (=
fwd)
=A0  =20
The complete context isn't shown, but it seems likely that there is a goto
out_free under line 1207, with no unlock on &adap->ptp_lock.

julia

---------- Forwarded message ----------
Date: Fri, 30 Jun 2017 11:54:23 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] cxgb4: Add PTP Hardware Clock (PHC) support

Hi Atul,

[auto build test WARNING on net-next/master]

url:=A0=A0=A0  https://github.com/0day-ci/linux/commits/Atul-Gupta/cxgb4-Ad=
d-PTP-Hardware-Clock-PHC-support/20170629-200758
:::::: branch date: 16 hours ago
:::::: commit date: 16 hours ago

>> drivers/net/ethernet/chelsio/cxgb4/sge.c:1190:2-8: preceding lock on lin=
e 1204

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 159226c60ceb77858018f6c31d17a575b3679b8a
vim +1190 drivers/net/ethernet/chelsio/cxgb4/sge.c

fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1184=A0=A0=A0=A0=A0=A0=A0=A0 /=
*
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1185=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 * The chip min packet length is 10 octets but play safe and reject
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1186=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 * anything shorter than an Ethernet header.
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1187=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 */
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1188=A0=A0=A0=A0=A0=A0=A0=A0 i=
f (unlikely(skb->len < ETH_HLEN)) {
a7525198a drivers/net/ethernet/chelsio/cxgb4/sge.c Eric W. Biederman=A0=A0=
=A0 2014-03-15=A0 1189=A0 out_free:=A0=A0=A0=A0 dev_kfree_skb_any(skb);
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01 @1190=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 return NETDEV_TX_OK;
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1191=A0=A0=A0=A0=A0=A0=A0=A0 }
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1192
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1193=A0=A0=A0=A0=A0=A0=A0=A0 /* Discard the packet if the=
 length is greater than mtu */
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1194=A0=A0=A0=A0=A0=A0=A0=A0 max_pkt_len =3D ETH_HLEN + d=
ev->mtu;
8d09e6b8b drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2016-07-28=A0 1195=A0=A0=A0=A0=A0=A0=A0=A0 if (skb_vlan_tagged(skb))
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1196=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 max_=
pkt_len +=3D VLAN_HLEN;
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1197=A0=A0=A0=A0=A0=A0=A0=A0 if (!skb_shinfo(skb)->gso_si=
ze && (unlikely(skb->len > max_pkt_len)))
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1198=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto=
 out_free;
637d3e997 drivers/net/ethernet/chelsio/cxgb4/sge.c Hariprasad Shenai=A0=A0=
=A0 2015-05-05=A0 1199
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1200=A0=A0=A0=A0=A0=A0=A0=A0 p=
i =3D netdev_priv(dev);
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1201=A0=A0=A0=A0=A0=A0=A0=A0 a=
dap =3D pi->adapter;
fd3a47900 drivers/net/cxgb4/sge.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 Dimitris Michailidis 2010-04-01=A0 1202=A0=A0=A0=A0=A0=A0=A0=A0 q=
idx =3D skb_get_queue_mapping(skb);
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2017-06-28=A0 1203=A0=A0=A0=A0=A0=A0=A0=A0 if (ptp_enabl=
ed) {
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2017-06-28 @1204=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 spin_lock(&adap->ptp_lock);
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2017-06-28=A0 1205=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 if (!(adap->ptp_tx_skb)) {
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2017-06-28=A0 1206=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 skb_shinfo(skb)->tx_flags |=3D SKBTX_I=
N_PROGRESS;
159226c60 drivers/net/ethernet/chelsio/cxgb4/sge.c Atul Gupta=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 2017-06-28=A0 1207=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 adap->ptp_tx_skb =3D skb_get(skb);

:::::: The code at line 1190 was first introduced by commit
:::::: fd3a47900b6f9fa72a4074ecb630f9dae62f1a95 cxgb4: Add packet queues an=
d packet DMA code

:::::: TO: Dimitris Michailidis <dm@chelsio.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 Intel Corporation
    =
