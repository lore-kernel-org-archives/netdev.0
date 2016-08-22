From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next V3 11/18] liquidio: link and control commands
Date: Mon, 22 Aug 2016 16:15:53 +0000
Message-ID: <CO2PR11MB00888B8EE6F66D0B1E8C58E697E80@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1471824765-26473-12-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0138.outbound.protection.outlook.com ([104.47.36.138]:28496
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752364AbcHVQP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 12:15:57 -0400
In-Reply-To: <1471824765-26473-12-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static inline void setup_link_status_change_wq(struct net_device *netdev=
)
> +{
> +	struct lio *lio =3D GET_LIO(netdev);
> +	struct octeon_device *oct =3D lio->oct_dev;
> +
> +	lio->link_status_wq.wq =3D alloc_workqueue("link-status",
> +						 WQ_MEM_RECLAIM, 0);
> +	if (!lio->link_status_wq.wq) {
> +		dev_err(&oct->pci_dev->dev, "unable to create cavium link
> status wq\n");
> +		return;
> +	}
> +	INIT_DELAYED_WORK(&lio->link_status_wq.wk.work,
> +			  octnet_link_status_change);
> +	lio->link_status_wq.wk.ctxptr =3D lio;
> +}

Don't you need to propagate the allocation failure?
Won't this wouldn't you still try to schedule the non-initialized workitem
on the non-existent workqueue later on?
