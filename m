From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: add new QCA alx ethernet driver
Date: Fri, 31 Aug 2012 16:20:58 -0400 (EDT)
Message-ID: <20120831.162058.2022883484639611493.davem@davemloft.net>
References: <1346083963-17610-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	xiong@qca.qualcomm.com, rodrigue@qca.qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346083963-17610-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cjren@qca.qualcomm.com>
Date: Tue, 28 Aug 2012 00:12:43 +0800

> +/*
> + * Definition to enable some features
> + */
> +#undef CONFIG_ALX_MSIX
> +#undef CONFIG_ALX_MSI
> +#undef CONFIG_ALX_MTQ
> +#undef CONFIG_ALX_MRQ
> +#undef CONFIG_ALX_RSS
> +/* #define CONFIG_ALX_MSIX */
> +#define CONFIG_ALX_MSI
> +#define CONFIG_ALX_MTQ
> +#define CONFIG_ALX_MRQ
> +#ifdef CONFIG_ALX_MRQ
> +#define CONFIG_ALX_RSS
> +#endif
> +

Get rid of all of these.  You may never use private feature control macros
in the CONFIG_* namespace, those are for the Kconfig system only.

Local controls of this nature are only appropriate for a driver amidst
development, and not a final version that should be included in the
upstream kernel tree.

You must remove all of these CPP macros, and all code that is currently
protected by the ones which are off.

Just so that your expectations are set appropriately, I anticipate
that there will be at least 5 more rounds of review for things of this
nature before we can even remotely consider adding this driver to the
tree.  This driver is very poorly written and is far away from meeting
our standards for incusion.
