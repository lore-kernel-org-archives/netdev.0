From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] b43: fix memory leak
Date: Fri, 19 Feb 2016 09:44:48 +0200
Message-ID: <87io1lqh3j.fsf@purkki.adurom.net>
References: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
	<20160218173212.03670d97@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, b43-dev@lists.infradead.org,
	Jia-Ju Bai <baijiaju1990@163.com>
To: Michael =?utf-8?Q?B=C3=BCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48103 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757342AbcBSHoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 02:44:54 -0500
In-Reply-To: <20160218173212.03670d97@wiggum> ("Michael =?utf-8?Q?B=C3=BCs?=
 =?utf-8?Q?ch=22's?= message of
	"Thu, 18 Feb 2016 17:32:12 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael B=C3=BCsch <m@bues.ch> writes:

> On Thu, 18 Feb 2016 18:04:36 +0530
> Sudip Mukherjee <sudipm.mukherjee@gmail.com> wrote:
>
>> From: Sudip Mukherjee <sudip@vectorindia.org>
>>=20
>> On error we jumped to the label bcma_out and returned the error code=
 but
>> we missed freeing dev.
>>=20
>> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
>> ---
>>  drivers/net/wireless/broadcom/b43/main.c | 1 +
>>  1 file changed, 1 insertion(+)
>>=20
>> diff --git a/drivers/net/wireless/broadcom/b43/main.c b/drivers/net/=
wireless/broadcom/b43/main.c
>> index c279211..78f670a 100644
>> --- a/drivers/net/wireless/broadcom/b43/main.c
>> +++ b/drivers/net/wireless/broadcom/b43/main.c
>> @@ -5671,6 +5671,7 @@ static int b43_bcma_probe(struct bcma_device *=
core)
>>  	wl =3D b43_wireless_init(dev);
>>  	if (IS_ERR(wl)) {
>>  		err =3D PTR_ERR(wl);
>> +		kfree(dev);
>>  		goto bcma_out;
>>  	}
>> =20
>
> We recently had a patch that fixes this, among more leaks. Subject:
> [PATCH v2 resend] b43: Fix memory leaks in b43_bus_dev_ssb_init and
> b43_bus_dev_bcma_init
>
> Please test that patch instead, so we can finally apply it.
>
> It needs to be tested on both ssb and bcma. Come on. This isn't too
> hard. :) Please somebody with any hardware test it. (I currently don'=
t
> have any b43 hardware)

And the patch can be downloaded from patchwork:

https://patchwork.kernel.org/patch/8049041/

--=20
Kalle Valo
