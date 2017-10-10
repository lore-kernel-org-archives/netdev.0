From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] rtl8xxxu: mark expected switch fall-throughs
Date: Tue, 10 Oct 2017 12:55:02 -0700
Message-ID: <94264677-cf71-86d5-5220-413cfbac8e90@gmail.com>
References: <20171010193027.GA23108@embeddedor.com>
 <5f5f0f54-d901-90be-9025-0a1c4b909368@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5f5f0f54-d901-90be-9025-0a1c4b909368-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/10/2017 12:35 PM, Jes Sorensen wrote:
> On 10/10/2017 03:30 PM, Gustavo A. R. Silva wrote:
>> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
>> where we are expecting to fall through.
> 
> While this isn't harmful, to me this looks like pointless patch churn
> for zero gain and it's just ugly.

That is the canonical way to tell static analyzers and compilers that
fall throughs are wanted and not accidental mistakes in the code. For
people that deal with these kinds of errors, it's quite helpful, unless
you suggest disabling that particular GCC warning specific for that
file/directory?

> 
> Jes
> 
> 
>> Cc: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: Gustavo A. R. Silva <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
>> ---
>>   drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 5 +++++
>>   1 file changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> index 7806a4d..e66be05 100644
>> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> @@ -1153,6 +1153,7 @@ void rtl8xxxu_gen1_config_channel(struct
>> ieee80211_hw *hw)
>>       switch (hw->conf.chandef.width) {
>>       case NL80211_CHAN_WIDTH_20_NOHT:
>>           ht = false;
>> +        /* fall through */
>>       case NL80211_CHAN_WIDTH_20:
>>           opmode |= BW_OPMODE_20MHZ;
>>           rtl8xxxu_write8(priv, REG_BW_OPMODE, opmode);
>> @@ -1280,6 +1281,7 @@ void rtl8xxxu_gen2_config_channel(struct
>> ieee80211_hw *hw)
>>       switch (hw->conf.chandef.width) {
>>       case NL80211_CHAN_WIDTH_20_NOHT:
>>           ht = false;
>> +        /* fall through */
>>       case NL80211_CHAN_WIDTH_20:
>>           rf_mode_bw |= WMAC_TRXPTCL_CTL_BW_20;
>>           subchannel = 0;
>> @@ -1748,9 +1750,11 @@ static int rtl8xxxu_identify_chip(struct
>> rtl8xxxu_priv *priv)
>>           case 3:
>>               priv->ep_tx_low_queue = 1;
>>               priv->ep_tx_count++;
>> +            /* fall through */
>>           case 2:
>>               priv->ep_tx_normal_queue = 1;
>>               priv->ep_tx_count++;
>> +            /* fall through */
>>           case 1:
>>               priv->ep_tx_high_queue = 1;
>>               priv->ep_tx_count++;
>> @@ -5691,6 +5695,7 @@ static int rtl8xxxu_set_key(struct ieee80211_hw
>> *hw, enum set_key_cmd cmd,
>>           break;
>>       case WLAN_CIPHER_SUITE_TKIP:
>>           key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
>> +        /* fall through */
>>       default:
>>           return -EOPNOTSUPP;
>>       }
>>
> 


-- 
Florian
