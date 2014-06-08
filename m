From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: hw.c: Cleaning up
 conjunction always evaluates to false
Date: Sun, 8 Jun 2014 03:15:14 +0200
Message-ID: <CAFo99gbO6CbxoYyqivFzYTKOjgyo034fHasFT2KuXb06oB9jSg@mail.gmail.com>
References: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<1670424.dXK6NPb10R@al>
	<CAFo99gZ+iu3FA9Nuwdo_AT1xZkno7w=6JidWYcm8g0bOvshwTw@mail.gmail.com>
	<5393A7D0.2080700@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Wu <peter@lekensteyn.nl>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5393A7D0.2080700@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

Good. New patches are on the way :)

Best regards
Rickard Strandqvist


2014-06-08 2:01 GMT+02:00 Larry Finger <Larry.Finger@lwfinger.net>:
> On 06/07/2014 10:24 AM, Rickard Strandqvist wrote:
>>
>> Hi!
>>
>> Yes, 0x3 was one of the most likely :)
>> But wanted someone who knows the code better would be heard.
>> All agreed? Then I do a new patch.
>>
>> Looks like it is the same error in the files below, I'll fix them all them
>> to.
>>
>> rtl8192cu/hw.c:1363:    if ((bt_msr & 0xfc) == MSR_AP)
>> rtl8192ce/hw.c:1209:    if ((bt_msr & 0xfc) == MSR_AP)
>> rtl8188ee/hw.c:1234:    if ((bt_msr & 0xfc) == MSR_AP)
>> rtl8192de/hw.c:1131:    if ((bt_msr & 0xfc) == MSR_AP)
>>
>>
>> Best regards
>> Rickard Strandqvist
>>
>>
>> 2014-06-07 17:02 GMT+02:00 Peter Wu <peter@lekensteyn.nl>:
>>>
>>> On Saturday 07 June 2014 16:30:19 Rickard Strandqvist wrote:
>>>>
>>>> Expression '(X & 0xfc) == 0x3' is always false
>>>
>>>
>>> While this is true, I believe that some other mistake is made.
>>>
>>>> I chose to remove this code, because it will not make any difference.
>>>> But obviously it is rather a properly designed if statement that is
>>>> needed.
>>>>
>>>> This was partly found using a static code analysis program called
>>>> cppcheck.
>>>>
>>>> Signed-off-by: Rickard Strandqvist
>>>> <rickard_strandqvist@spectrumdigital.se>
>>>> ---
>>>>   drivers/net/wireless/rtlwifi/rtl8192de/hw.c |    5 +----
>>>>   1 file changed, 1 insertion(+), 4 deletions(-)
>>>>
>>>> diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>>>> b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>>>> index 2b08671..a1520d5 100644
>>>> --- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>>>> +++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
>>>> @@ -1128,10 +1128,7 @@ static int _rtl92de_set_media_status(struct
>>>> ieee80211_hw *hw,
>>>>        }
>>>>        rtl_write_byte(rtlpriv, REG_CR + 2, bt_msr);
>>>>        rtlpriv->cfg->ops->led_control(hw, ledaction);
>>>> -     if ((bt_msr & 0xfc) == MSR_AP)
>>>
>>>
>>> If you look a few lines up, then you see that bt_msr is OR-ed with MSR_AP
>>> for AP interfaces. The 0xfc should be 0x03, see other drivers for
>>> example:
>>>
>>> rtl8723ae/hw.c:1112:    if ((bt_msr & 0x03) == MSR_AP)
>>> rtl8723be/hw.c:1200:    if ((bt_msr & 0x03) == MSR_AP)
>>> rtl8192cu/hw.c:1363:    if ((bt_msr & 0xfc) == MSR_AP)
>>> rtl8192ce/hw.c:1209:    if ((bt_msr & 0xfc) == MSR_AP)
>>> rtl8188ee/hw.c:1234:    if ((bt_msr & 0xfc) == MSR_AP)
>>> rtl8192de/hw.c:1131:    if ((bt_msr & 0xfc) == MSR_AP)
>>>
>>>> -             rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
>>>> -     else
>>>> -             rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
>>>> +     rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
>>>>        return 0;
>>>>   }
>
>
> Peter,
>
> As you have learned here, automatically making changes suggested by some
> tool may convert a visible bug into one that is invisible, and only found by
> a detailed line-by-line examination of the code, and that is unlikely to
> happen. Please be careful.
>
> From everything I see, the test in all drivers should be
>
>         if ((bt_msr & MSR_AP) == MSR_AP)
>
> Larry
>
