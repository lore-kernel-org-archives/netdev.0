From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH v3 net-next 03/13] net: hisilicon: cleanup to prepare for
 other cases
Date: Thu, 2 Jun 2016 19:04:47 +0800
Message-ID: <575012CF.9090306@huawei.com>
References: <1464611664-93775-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1464611664-93775-4-git-send-email-Yisen.Zhuang@huawei.com>
 <20160601.160706.1959937095056503271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <rjw@rjwysocki.net>, <lenb@kernel.org>, <fengguang.wu@intel.com>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<ivecera@redhat.com>, <f.fainelli@gmail.com>,
	<haifeng.wei@huawei.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20160601.160706.1959937095056503271.davem@davemloft.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for your comment, i will use dev name of this mdio bus instead o=
f address.

Thanks,

Yisen

=E5=9C=A8 2016/6/2 7:07, David Miller =E5=86=99=E9=81=93:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 30 May 2016 20:34:14 +0800
>=20
>> -static void hns_mdio_bus_name(char *name, struct device_node *np)
>> +static void hns_mdio_bus_name(char *name, phys_addr_t addr)
>>  {
>> -	const u32 *addr;
>> -	u64 taddr =3D OF_BAD_ADDR;
>> -
>> -	addr =3D of_get_address(np, 0, NULL, NULL);
>> -	if (addr)
>> -		taddr =3D of_translate_address(np, addr);
>> -
>> -	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
>> -		 (unsigned long long)taddr);
>> +	snprintf(name, MII_BUS_ID_SIZE,
>> +		 "hns-mdio@%llx", (unsigned long long)addr);
>=20
> This is a really bad idea.
>=20
> You're passing in the resource address in here, which can be a bus
> address.
>=20
> And on a machine with multiple bus domains, the same address can be
> used multiple times.  They are not unique at all in a multi-domain
> system.
>=20
> .
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
