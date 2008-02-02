From: =?UTF-8?B?TWlndWVsIEJvdMOzbg==?= <mboton@gmail.com>
Subject: Re: linux-2.6.24 compile error in drivers/net/b44.c
Date: Sat, 02 Feb 2008 20:58:52 +0100
Message-ID: <47A4CB7C.3010507@gmail.com>
References: <47A3CC70.8090900@cn.fujitsu.com> <47A3F6DC.1000903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	linville@tuxdriver.com
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:10660 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855AbYBBUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 15:00:13 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1414142fga.17
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 12:00:11 -0800 (PST)
In-Reply-To: <47A3F6DC.1000903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan wrote:
> Add CCs:
>=20
> CC: mboton@gmail.com
> CC: zambrano@broadcom.com
> CC: linville@tuxdriver.com
>=20
> Li Zefan wrote:
>> drivers/net/b44.c: In function 'b44_remove_one':
>> drivers/net/b44.c:2231: error: implicit declaration of function 'ssb=
_pcihost_set_power_state'
>> make[2]: *** [drivers/net/b44.o] Error 1
>> make[1]: *** [drivers/net] Error 2
>>
>> I think it is caused by:
>>
>> CONFIG_SSB_PCIHOST=3Dn
>> CONFIG_B44=3Dy
>>
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

This patch should fix b44 errors when 'SSB_PCIHOST' is not enabled.

Signed-off-by: Miguel Bot=C3=B3n <mboton@gmail.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index ea2a2b5..d081234 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2228,7 +2228,9 @@ static void __devexit b44_remove_one(struct ssb_d=
evice *sdev)
 	unregister_netdev(dev);
 	ssb_bus_may_powerdown(sdev->bus);
 	free_netdev(dev);
+#ifdef B44_PCI
 	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
+#endif
 	ssb_set_drvdata(sdev, NULL);
 }
=20
@@ -2257,7 +2259,9 @@ static int b44_suspend(struct ssb_device *sdev, p=
m_message_t state)
 		b44_setup_wol(bp);
 	}
=20
+#ifdef B44_PCI
 	ssb_pcihost_set_power_state(sdev, PCI_D3hot);
+#endif
 	return 0;
 }
=20
--
	Miguel Bot=C3=B3n
