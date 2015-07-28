From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: Re: [PATCH] rsi: Fix failure to load firmware after memory leak fix
 and fix the leak
Date: Tue, 28 Jul 2015 07:53:21 +0200
Message-ID: <55B718D1.2030803@topic.nl>
References: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl> <87wpxlao8l.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-wireless@vger.kernel.org>, <khoroshilov@ispras.ru>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wpxlao8l.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=EF=BB=BFOn 27-07-15 12:28, Kalle Valo wrote:
> Mike Looijmans <mike.looijmans@topic.nl> writes:
>
>> Fixes commit eae79b4f3e82ca63a53478a161b190a0d38fe526 ("rsi: fix mem=
ory leak
>> in rsi_load_ta_instructions()") which stopped the driver from functi=
oning.
>
> You can abbreviate the commit id:
>
> Fixes commit eae79b4f3e82 ("rsi: fix memory leak in
> rsi_load_ta_instructions()") which stopped the driver from functionin=
g.
>
>> Firmware data has been allocated using vmalloc(), resulting in memor=
y
>> that cannot be used for DMA. Hence the firmware was first copied to =
a
>> buffer allocated with kmalloc() in the original code. This patch rev=
erts
>> the commit and only calls "kfree()" to release the buffer after send=
ing
>> the data. This fixes the memory leak without breaking the driver.
>>
>> Add a comment to the kmemdup() calls to explain why this is done.
>>
>> Tested on a Topic Miami-Florida board which contains the rsi SDIO ch=
ip.
>>
>> Also added the same kfree() call to the USB glue driver. This was no=
t
>> tested on actual hardware though, as I only have the SDIO version.
>>
>> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
>
> Add this before Signed-off-by line:
>
> Fixes: eae79b4f3e82 ("rsi: fix memory leak in rsi_load_ta_instruction=
s()")
>
>> Cc: stable@vger.kernel.org
>
> Also no need to send email to stable@vger.kernel.org list, this line =
is
> enough and the stable team will pick the commit automatically.

I wondered why that happened, and just noticed that git send-email=20
automatically added this to the recipients. So it happened for v2 as we=
ll,=20
sorry for that.



Kind regards,

Mike Looijmans
System Expert

TOPIC Embedded Products
Eindhovenseweg 32-C, NL-5683 KH Best
Postbus 440, NL-5680 AK Best
Telefoon: +31 (0) 499 33 69 79
Telefax: +31 (0) 499 33 69 70
E-mail: mike.looijmans@topicproducts.com
Website: www.topicproducts.com

Please consider the environment before printing this e-mail
