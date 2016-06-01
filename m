From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 03/13] net: hisilicon: cleanup to prepare
 for other cases
Date: Wed, 01 Jun 2016 16:07:06 -0700 (PDT)
Message-ID: <20160601.160706.1959937095056503271.davem@davemloft.net>
References: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
	<1464611664-93775-4-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@rjwysocki.net, lenb@kernel.org, fengguang.wu@intel.com,
	andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
	ivecera@redhat.com, f.fainelli@gmail.com, haifeng.wei@huawei.com,
	charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen.Zhuang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464611664-93775-4-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Date: Mon, 30 May 2016 20:34:14 +0800

> -static void hns_mdio_bus_name(char *name, struct device_node *np)
> +static void hns_mdio_bus_name(char *name, phys_addr_t addr)
>  {
> -	const u32 *addr;
> -	u64 taddr = OF_BAD_ADDR;
> -
> -	addr = of_get_address(np, 0, NULL, NULL);
> -	if (addr)
> -		taddr = of_translate_address(np, addr);
> -
> -	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
> -		 (unsigned long long)taddr);
> +	snprintf(name, MII_BUS_ID_SIZE,
> +		 "hns-mdio@%llx", (unsigned long long)addr);

This is a really bad idea.

You're passing in the resource address in here, which can be a bus
address.

And on a machine with multiple bus domains, the same address can be
used multiple times.  They are not unique at all in a multi-domain
system.
