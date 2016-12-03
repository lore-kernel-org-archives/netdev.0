From: Bhumika Goyal <bhumirks@gmail.com>
Subject: Re: [PATCH] net: wireless: realtek: constify rate_control_ops structures
Date: Sat, 3 Dec 2016 08:00:59 +0530
Message-ID: <CAOH+1jG=-AYsNrjAD9-8N+m-KaqZbe4bkLq8Wj90bDHhNa_hKA@mail.gmail.com>
References: <1480672254-4986-1-git-send-email-bhumirks@gmail.com> <0f223291-734f-7658-57b7-18e962d15823@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julia Lawall <julia.lawall@lip6.fr>, chaoming_li@realsil.com.cn,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0f223291-734f-7658-57b7-18e962d15823@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 3, 2016 at 2:09 AM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 12/02/2016 03:50 AM, Bhumika Goyal wrote:
>>
>> The structures rate_control_ops are only passed as an argument to the
>> functions ieee80211_rate_control_{register/unregister}. This argument is
>> of type const, so rate_control_ops having this property can also be
>> declared as const.
>> Done using Coccinelle:
>>
>> @r1 disable optional_qualifier @
>> identifier i;
>> position p;
>> @@
>> static struct rate_control_ops i@p = {...};
>>
>> @ok1@
>> identifier r1.i;
>> position p;
>> @@
>> ieee80211_rate_control_register(&i@p)
>>
>> @ok2@
>> identifier r1.i;
>> position p;
>> @@
>> ieee80211_rate_control_unregister(&i@p)
>>
>> @bad@
>> position p!={r1.p,ok1.p,ok2.p};
>> identifier r1.i;
>> @@
>> i@p
>>
>> @depends on !bad disable optional_qualifier@
>> identifier r1.i;
>> @@
>> static
>> +const
>> struct rate_control_ops i={...};
>>
>> @depends on !bad disable optional_qualifier@
>> identifier r1.i;
>> @@
>> +const
>> struct rate_control_ops i;
>>
>> File size before:
>>    text    data     bss     dec     hex filename
>>    1991     104       0    2095     82f wireless/realtek/rtlwifi/rc.o
>>
>> File size after:
>>    text    data     bss     dec     hex filename
>>    2095       0       0    2095     wireless/realtek/rtlwifi/rc.o
>>
>> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
>> ---
>>  drivers/net/wireless/realtek/rtlwifi/rc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/realtek/rtlwifi/rc.c
>> b/drivers/net/wireless/realtek/rtlwifi/rc.c
>> index ce8621a..107c13c 100644
>> --- a/drivers/net/wireless/realtek/rtlwifi/rc.c
>> +++ b/drivers/net/wireless/realtek/rtlwifi/rc.c
>> @@ -284,7 +284,7 @@ static void rtl_rate_free_sta(void *rtlpriv,
>>         kfree(rate_priv);
>>  }
>>
>> -static struct rate_control_ops rtl_rate_ops = {
>> +static const struct rate_control_ops rtl_rate_ops = {
>>         .name = "rtl_rc",
>>         .alloc = rtl_rate_alloc,
>>         .free = rtl_rate_free,
>>
>
> The content of your patch is OK; however, your subject is not. By
> convention, "net: wireless: realtek:" is assumed. We do, however, include
> "rtlwifi:" to indicate which part of drivers/net/wireless/realtek/ is
> referenced.
>
Ok, I will send a v2 with the correct subject. Thanks for the input.

Thanks,
Bhumika

> NACK
>
> Larry
>
