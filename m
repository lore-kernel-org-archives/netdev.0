From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: linux-2.6.24 compile error in drivers/net/b44.c
Date: Sun, 03 Feb 2008 09:57:11 +0800
Message-ID: <47A51F77.60509@cn.fujitsu.com>
References: <47A3CC70.8090900@cn.fujitsu.com> <47A3F6DC.1000903@cn.fujitsu.com> <47A4CB7C.3010507@gmail.com> <47A51E86.8080305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	linville@tuxdriver.com
To: =?UTF-8?B?TWlndWVsIEJvdMOzbg==?= <mboton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54869 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933771AbYBCB6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 20:58:06 -0500
In-Reply-To: <47A51E86.8080305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan wrote:
> Miguel Bot=C3=B3n =E5=86=99=E9=81=93:
>> Li Zefan wrote:
>>> Add CCs:
>>>
>>> CC: mboton@gmail.com
>>> CC: zambrano@broadcom.com
>>> CC: linville@tuxdriver.com
>>>
>>> Li Zefan wrote:
>>>> drivers/net/b44.c: In function 'b44_remove_one':
>>>> drivers/net/b44.c:2231: error: implicit declaration of function 's=
sb_pcihost_set_power_state'
>>>> make[2]: *** [drivers/net/b44.o] Error 1
>>>> make[1]: *** [drivers/net] Error 2
>>>>
>>>> I think it is caused by:
>>>>
>>>> CONFIG_SSB_PCIHOST=3Dn
>>>> CONFIG_B44=3Dy
>>>>
>> This patch should fix b44 errors when 'SSB_PCIHOST' is not enabled.
>>
>=20
> I tried the patch, but it does't work, same compile error. :(
>=20
> If .config is needed, tell me and I will attach it.
>=20

Sorry, I just made a mistake, actually the patch works.

Thanks!

>> Signed-off-by: Miguel Bot=C3=B3n <mboton@gmail.com>
>>
>> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
>> index ea2a2b5..d081234 100644
>> --- a/drivers/net/b44.c
>> +++ b/drivers/net/b44.c
>> @@ -2228,7 +2228,9 @@ static void __devexit b44_remove_one(struct ss=
b_device *sdev)
>>  	unregister_netdev(dev);
>>  	ssb_bus_may_powerdown(sdev->bus);
>>  	free_netdev(dev);
>> +#ifdef B44_PCI
>>  	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
>> +#endif
>>  	ssb_set_drvdata(sdev, NULL);
>>  }
>> =20
>> @@ -2257,7 +2259,9 @@ static int b44_suspend(struct ssb_device *sdev=
, pm_message_t state)
>>  		b44_setup_wol(bp);
>>  	}
>> =20
>> +#ifdef B44_PCI
>>  	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
>> +#endif
>>  	return 0;
>>  }
>> =20
>> --
>> 	Miguel Bot=C3=B3n
>>
>>
>=20
>=20
