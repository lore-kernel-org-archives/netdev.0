From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 2/5] liquidio CN23XX: sriov enable
Date: Sun, 11 Sep 2016 12:53:33 +0000
Message-ID: <DM5PR11MB1723FF049A66E652649DB67197FC0@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1473451707-26397-3-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-cys01nam02on0118.outbound.protection.outlook.com ([104.47.37.118]:59363
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755569AbcIKMxg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Sep 2016 08:53:36 -0400
In-Reply-To: <1473451707-26397-3-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%llx\n",
> -		"CN23XX_WIN_WR_MASK_REG",
....
> +	pr_devel("%s[%llx] : 0x%llx\n",
> +		 "CN23XX_WIN_WR_MASK_REG",
It looks like at least half of this patch [and I think it's also true for o=
ther
patches in this series] merely change debug prints.
Why not extract all of those to a single patch?

> +static unsigned int num_vfs[2] =3D { 0, 0 }; module_param_array(num_vfs,
> +uint, NULL, 0444); MODULE_PARM_DESC(num_vfs, "two comma-separated
> +unsigned integers that specify number of VFs for PF0 (left of the
> +comma) and PF1 (right of the comma); for 23xx only");

I believe we're way past the days where it's acceptable to enable IOV
Via module parameters; you have sysfs to dynamically enable VFs.

BTW, I glanced at pci-iov-howto.txt and noticed it still lists having a
module-parameter as control node for activating this feature;
But I believe it's been years since this has been considered a valid
Method for new drivers [I recall this was forbidden when we've added
bnx2x IOV support, and that was more than 3.5 years ago].
Perhaps it would be better to rephrase it so it would be obvious this
is a legacy sort of configuration [and not merely 'less preferable']?

> +static unsigned int num_queues_per_pf[2] =3D { 0, 0 };
> +module_param_array(num_queues_per_pf, uint, NULL, 0444);
> +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated unsigned
> +integers that specify number of queues per PF0 (left of the comma) and
> +PF1 (right of the comma); for 23xx only");
> +
> +static unsigned int num_queues_per_vf[2] =3D { 0, 0 };
> +module_param_array(num_queues_per_vf, uint, NULL, 0444);
> +MODULE_PARM_DESC(num_queues_per_vf, "two comma-separated unsigned
> +integers that specify number of queues per VFs for PF0 (left of the
> +comma) and PF1 (right of the comma); for 23xx only");

I don't believe this is a suitable solution as this is a generic problem -
how to split resources between PFs and their various VFs.
I don't believe there's good infrastructure for it today, though.
[Besides, you're introducing new module parameters...]
