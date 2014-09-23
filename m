From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: Fix off by one bug in brcmf_count_20mhz_channels()
Date: Tue, 23 Sep 2014 11:33:04 +0200
Message-ID: <54213E50.4020207@broadcom.com>
References: <1411253932-27973-1-git-send-email-emilgoode@gmail.com> <541FF25B.9000404@broadcom.com> <20140922230833.GB10356@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Emil Goode <emilgoode@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140922230833.GB10356@lianli>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/14 01:08, Emil Goode wrote:
> Hello Arend,
>
> Sorry for the late reply. I have attached a kernel log with brcmfmac
> debugging enabled (without my patch applied).
>
> Let me know if I can provide any other useful information.

No problem, Emil

I was wondering what was returned on "chanspecs" query. So 17 channel 
configs which is expected.

Regards,
Arend

> Best regards,
>
> Emil
>
> On Mon, Sep 22, 2014 at 11:56:43AM +0200, Arend van Spriel wrote:
>> On 09/21/14 00:58, Emil Goode wrote:
>>> In the brcmf_count_20mhz_channels function we are looping through a list
>>> of channels received from firmware. Since the index of the first channel
>>> is 0 the condition leads to an off by one bug. This is causing us to hit
>>> the WARN_ON_ONCE(1) calls in the brcmu_d11n_decchspec function, which is
>>> how I discovered the bug.
>>
>> The fix is fine. Would like to know what exactly is going wrong. Can you
>> provide a kernel log with brcmfmac debugging enabled, ie. insmod brcmfmac.ko
>> debug=0x1416
>>
>> Regards,
>> Arend
>>
>>> Introduced by:
>>> commit b48d891676f756d48b4d0ee131e4a7a5d43ca417
>>> ("brcmfmac: rework wiphy structure setup")
>>>
>>> Signed-off-by: Emil Goode<emilgoode@gmail.com>
>>> ---
>>>   drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>> index 02fe706..93b5dd9 100644
>>> --- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>>> @@ -4918,7 +4918,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_cfg80211_info *cfg,
>>>   	struct brcmu_chan ch;
>>>   	int i;
>>>
>>> -	for (i = 0; i<= total; i++) {
>>> +	for (i = 0; i<   total; i++) {
>>>   		ch.chspec = (u16)le32_to_cpu(chlist->element[i]);
>>>   		cfg->d11inf.decchspec(&ch);
>>>
>>

