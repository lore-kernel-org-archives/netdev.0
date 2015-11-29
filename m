From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc for loading firmware using api1 method
Date: Sun, 29 Nov 2015 02:53:34 +0200
Message-ID: <CAHp75VcVdMNrxvedCB_OmJw7upTPJq8T8tKxfBn_moYGj6S19g@mail.gmail.com>
References: <1444972259-24260-1-git-send-email-motobud@gmail.com>
	<CAP+RiCA6wasaiMCYEJ-8gaiVMi5JP2JT6A1bGm9nHJ9CA+Ow5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath6kl@lists.infradead.org
To: Brent Taylor <motobud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP+RiCA6wasaiMCYEJ-8gaiVMi5JP2JT6A1bGm9nHJ9CA+Ow5g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 28, 2015 at 8:58 PM, Brent Taylor <motobud@gmail.com> wrote:
> Sorry, the first e-mail was sent via gmail and I forgot about sending
> it in plain text mode.
>
> Whats the status on this patch?  I don't see it on patchwork anymore
> nor is it in any of the git trees I checked.
>

You forget to use kvfree() instead of kfree() in core.c.

> Thanks,
> Brent
>
> On Fri, Oct 16, 2015 at 12:10 AM, Brent Taylor <motobud@gmail.com> wrote:
>> Signed-off-by: Brent Taylor <motobud@gmail.com>
>> ---
>>  drivers/net/wireless/ath/ath6kl/init.c | 15 +++++++++++----
>>  1 file changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
>> index 6e473fa..2155739 100644
>> --- a/drivers/net/wireless/ath/ath6kl/init.c
>> +++ b/drivers/net/wireless/ath/ath6kl/init.c
>> @@ -673,10 +673,17 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>>                 return ret;
>>
>>         *fw_len = fw_entry->size;
>> -       *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>> -
>> -       if (*fw == NULL)
>> -               ret = -ENOMEM;
>> +       if (&ar->fw == fw) {
>> +               *fw = vmalloc(fw_entry->size);
>> +               if (*fw == NULL)
>> +                       ret = -ENOMEM;
>> +               else
>> +                       memcpy(*fw, fw_entry->data, fw_entry->size);
>> +       } else {
>> +               *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>> +               if (*fw == NULL)
>> +                       ret = -ENOMEM;
>> +       }
>>
>>         release_firmware(fw_entry);
>>
>> --
>> 2.6.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
