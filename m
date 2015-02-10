From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] rtlwifi: ratelimit skb allocation failure message
Date: Tue, 10 Feb 2015 13:52:23 +0000
Message-ID: <54DA0D17.7070403@canonical.com>
References: <1423558471-27278-1-git-send-email-colin.king@canonical.com>	<1423574228.28434.22.camel@edumazet-glaptop2.roam.corp.google.com> <87a90lop1x.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a90lop1x.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/15 13:48, Kalle Valo wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> On Tue, 2015-02-10 at 08:54 +0000, Colin King wrote:
>>> From: Colin Ian King <colin.king@canonical.com>
>>>
>>> when running low on memory I noticed rtlwifi was producing a large
>>> quantity of repeated skb allocation failures messages.  This should
>>> be ratelimited to reduce the noise.
>>>
>>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>>> ---
>>>  drivers/net/wireless/rtlwifi/pci.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
>>> index c70efb9..ca0fd50 100644
>>> --- a/drivers/net/wireless/rtlwifi/pci.c
>>> +++ b/drivers/net/wireless/rtlwifi/pci.c
>>> @@ -817,7 +817,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
>>>  		/* get a new skb - if fail, old one will be reused */
>>>  		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
>>>  		if (unlikely(!new_skb)) {
>>> -			pr_err("Allocation of new skb failed in %s\n",
>>> +			pr_err_ratelimited("Allocation of new skb failed in %s\n",
>>>  			       __func__);
>>
>> Or even better, remove the message.
> 
> There's actually a pending patch for that, I'll send it to Dave ASAP:
> 
> https://patchwork.kernel.org/patch/5671121/
> 
Thanks!
