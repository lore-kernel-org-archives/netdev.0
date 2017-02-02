From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 11/12] bnxt_en: Add basic XDP support.
Date: Thu, 2 Feb 2017 17:18:35 +0000
Message-ID: <BL2PR07MB2306262459A2F72761A5C28C8D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <1486054540-366-12-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0051.outbound.protection.outlook.com ([104.47.33.51]:45313
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751414AbdBBRSi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 12:18:38 -0500
In-Reply-To: <1486054540-366-12-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +config BNXT_XDP
> +	bool "Xpress Data Path (XDP) driver support"
> +	default n
> +	depends on BNXT && BPF
> +	---help---
> +	  Say Y here if you want to enable XDP in the driver to support
> +	  eBPF programs in the fast path.
> +

Wasn't it recently discussed that per-feature option is preferable
to a per-feature per-device option?
Assuming BPF > XDP and thus shouldn't directly imply that XDP
should be supported, perhaps the right thing is to add a global
XDP config option?

> +	if (prog && bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU) {
> +		netdev_err(dev, "MTU %d larger than largest XDP supported
> MTU %d.\n",
> +			   bp->dev->mtu, BNXT_MAX_PAGE_MODE_MTU);
> +		return -EOPNOTSUPP;
> +	}

Is it O.k. to print with netdev_err() for a user-provided unsupported
configuration? Shouldn't that be limited?

> +		bool sh =3D (bp->flags & BNXT_FLAG_SHARED_RINGS) ? true :
> false;

Didn't you already check this flag is set?
