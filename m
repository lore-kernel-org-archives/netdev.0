From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 0/7] net: use platform_{get,set}_drvdata()
Date: Fri, 16 Aug 2013 03:04:44 +0400
Message-ID: <520D5E8C.4020600@cogentembedded.com>
References: <520CD11D.8010202@huawei.com> <20130815.152359.920302339053249583.davem@davemloft.net> <20130815.153903.859166500375208182.davem@davemloft.net> <520D5B88.7080304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lizefan@huawei.com, leoli@freescale.com,
	linuxppc-dev@lists.ozlabs.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, gregkh@linuxfoundation.org,
	jg1.han@samsung.com
To: David Miller <davem@davemloft.net>, clbchenlibo.chen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:44196 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3HOXEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 19:04:38 -0400
Received: by mail-la0-f50.google.com with SMTP id ek20so960734lab.23
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 16:04:36 -0700 (PDT)
In-Reply-To: <520D5B88.7080304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2013 02:51 AM, Sergei Shtylyov wrote:

>>> From: Libo Chen <clbchenlibo.chen@huawei.com>
>>> Date: Thu, 15 Aug 2013 21:01:17 +0800

>>>> Use the wrapper functions for getting and setting the driver data =
using
>>>> platform_device instead of using dev_{get,set}_drvdata() with &pde=
v->dev,
>>>> so we can directly pass a struct platform_device.

>>>> changelog v3:
>>>>     remove modify about dev_set_drvdata()
>>>> changelog v2:
>>>>     this version add modify record about dev_set_drvdata().

>>> Series applied.

>> Actually, I had to revert, these patches break the build.

>> drivers/net/ethernet/sun/sunhme.c: In function =A1happy_meal_pci_pro=
be=A2:
>> drivers/net/ethernet/sun/sunhme.c:3114:2: error: implicit declaratio=
n of
>> function =A1platform_set_drvdata=A2 [-Werror=3Dimplicit-function-dec=
laration]
>> drivers/net/ethernet/sun/sunhme.c: In function =A1happy_meal_pci_rem=
ove=A2:
>> drivers/net/ethernet/sun/sunhme.c:3162:9: error: implicit declaratio=
n of
>> function =A1platform_get_drvdata=A2 [-Werror=3Dimplicit-function-dec=
laration]
>> drivers/net/ethernet/sun/sunhme.c:3162:26: warning: initialization m=
akes
>> pointer from integer without a cast [enabled by default]

>     Hm, patch #5 was clearly defective as it tried to call
> platform_{get|set}_drvdata() on PCI devices -- I've read the patch bu=
t
> overlooked that. And the driver lacks #include <linux/platform_device=
=2Eh>, so
> I'm not sure it always compiled flawlessly.

    Ah, the platform code is protected by #ifdef CONFIG_SBUS... probabl=
y some=20
header #include's <linux/platform_device.h>?

WBR, Sergei
