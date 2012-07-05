From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH 4 2/4] NET ethernet introduce mac_platform helper
Date: Thu, 05 Jul 2012 11:20:31 +0800
Message-ID: <4FF507FF.3000604@linaro.org>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>  <20120705024446.26317.49693.stgit@build.warmcat.com> <1341457963.2058.13.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-omap@vger.kernel.org, s-jan@ti.com, arnd@arndb.de,
	patches@linaro.org, tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org,
	linux-arm-kernel@lists.infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341457963.2058.13.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/12 11:12, the mail apparently from Joe Perches included:

Thanks for the comments.

>> This introduces a small helper in net/ethernet, which registers a ne=
twork
>> notifier at core_initcall time, and accepts registrations mapping ex=
pected
>> asynchronously-probed network device paths (like, "usb1/1-1/1-1.1/1-=
1.1:1.0")
>> and the MAC that is needed to be assigned to the device when it appe=
ars.
>
> The mac prefix is poor.  I think eth_mac is better.

OK.

>> diff --git a/net/ethernet/mac-platform.c b/net/ethernet/mac-platform=
=2Ec
> []
>> +static int mac_platform_netdev_event(struct notifier_block *this,
>> +						unsigned long event, void *ptr)
>
> alignment to parenthesis please.

OK.  Although different places in the kernel seem to have different=20
expectations about that.

>> +int mac_platform_register_device_macs(const struct mac_platform *ma=
cs)
>> +{
> []
>> +		next =3D kmalloc(sizeof(struct mac_platform), GFP_KERNEL);
>> +		if (!next) {
>> +			ret =3D -ENOMEM;
>> +			goto bail;
>> +		}
>> +
>> +		next->device_path =3D kmalloc(strlen(macs->device_path) + 1,
>> +								   GFP_KERNEL);
>> +		if (!next->device_path) {
>> +			ret =3D -ENOMEM;
>> +			goto bail;
>> +		}
>> +
>> +		strcpy(next->device_path, macs->device_path);
>> +		memcpy(next->mac, macs->mac, sizeof macs->mac);
>
> kmemdup and kstrdup()

OK

>> +		list_add(&next->list, &mac_platform_list);
>> +
>> +		macs++;
>> +	}
>> +
>> +bail:
>> +	mutex_unlock(&mac_platform_mutex);
>> +
>> +	return ret;
>> +}
>
> leaking memory on failures.

Right... I'll fix these and wait for more comments.

Thanks again for the review.

-Andy

--=20
Andy Green | TI Landing Team Leader
Linaro.org =E2=94=82 Open source software for ARM SoCs | Follow Linaro
http://facebook.com/pages/Linaro/155974581091106  -=20
http://twitter.com/#!/linaroorg - http://linaro.org/linaro-blog
