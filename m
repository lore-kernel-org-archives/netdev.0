From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH V2] wireless: rtlwifi: Replace variable with a brake
Date: Sun, 22 Sep 2013 22:24:22 +0200
Message-ID: <CA+MoWDpo-CD7B-DKmLX1wZ7AEyzp7+KjpEEE2-eGP8evYC4P=Q@mail.gmail.com>
References: <1379879410-22787-1-git-send-email-peter.senna@gmail.com>
	<523F4B76.80507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	Joe Perches <joe@perches.com>,
	John Linville <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <523F4B76.80507@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 22, 2013 at 9:56 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 09/22/2013 11:50 PM, Peter Senna Tschudin wrote:
>
>    You have a typo in the subject -- "brake" is a device to stop a vehicle.
> :-)
Thanks, there was other similar typo after ---

>
>
>> This patch removes the variable continual, and change the while loop
>> to break when efuse_data == 0xFF.
>
>
>> Tested by compilation only.
>
>
>> CC: Joe Perches <joe@perches.com>
>> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>> ---
>> Changes from V1:
>>   - Fix the indetation
>>   - Remove remaining } from removed else
>
>
>> Please ignore the patch:
>> [PATCH 12/19] wireless: Change variable type to bool
>
>
>> And apply this one instead.
>
>
>> The variable continual was declared as int, but was used as bool. I
>> sent previous patch changing the variable type to bool, but Joe Perches
>> proposed that removing the variable and adding a brake would be better.
>
>
>>   drivers/net/wireless/rtlwifi/efuse.c | 18 ++++++++----------
>>   1 file changed, 8 insertions(+), 10 deletions(-)
>
>
>> diff --git a/drivers/net/wireless/rtlwifi/efuse.c
>> b/drivers/net/wireless/rtlwifi/efuse.c
>> index 838a1ed..2aedd9f 100644
>> --- a/drivers/net/wireless/rtlwifi/efuse.c
>> +++ b/drivers/net/wireless/rtlwifi/efuse.c
>> @@ -1203,20 +1203,18 @@ static void efuse_power_switch(struct ieee80211_hw
>> *hw, u8 write, u8 pwrstate)
>>
>>   static u16 efuse_get_current_size(struct ieee80211_hw *hw)
>>   {
>> -       int continual = true;
>>         u16 efuse_addr = 0;
>>         u8 hworden;
>>         u8 efuse_data, word_cnts;
>>
>> -       while (continual && efuse_one_byte_read(hw, efuse_addr,
>> &efuse_data)
>> -              && (efuse_addr < EFUSE_MAX_SIZE)) {
>> -               if (efuse_data != 0xFF) {
>> -                       hworden = efuse_data & 0x0F;
>> -                       word_cnts = efuse_calculate_word_cnts(hworden);
>> -                       efuse_addr = efuse_addr + (word_cnts * 2) + 1;
>> -               } else {
>> -                       continual = false;
>> -               }
>> +       while (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
>> +                                       (efuse_addr < EFUSE_MAX_SIZE)) {
>
>
>    Start this line under efuse_one_byte_read, please. Also, parens are not
> needed.
Fixed on V3.

Thanks!

>
> WBR, Sergei
>



-- 
Peter
