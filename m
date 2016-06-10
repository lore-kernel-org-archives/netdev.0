From: Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station ioctl
 file
Date: Fri, 10 Jun 2016 15:33:45 -0400
Message-ID: <8dc6e64a-3429-4bed-e5c9-da6880eb9505@osg.samsung.com>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
 <1465232558-31678-3-git-send-email-javier@osg.samsung.com>
 <87wplxdsln.fsf@kamboji.qca.qualcomm.com>
 <12ccd90e-e3eb-ecac-b23f-8124b0db32ad@osg.samsung.com>
 <2b5e5833ecc74a2b9cd822e8455cd0af@SC-EXCH04.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Shengzhen Li <szli-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Enric Balletbo i Serra <enric.balletbo-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2b5e5833ecc74a2b9cd822e8455cd0af-uAViF8V/CPOq90oVIqnETxL4W9x8LtSr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Amitkumar,

On 06/10/2016 12:26 PM, Amitkumar Karwar wrote:
> Hi Kalle/Javier,
> 
>> From: Javier Martinez Canillas [mailto:javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org]
>> Sent: Friday, June 10, 2016 8:07 PM
>> To: Kalle Valo
>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Julian Calaby; Shengzhen Li; Enric
>> Balletbo i Serra; Amitkumar Karwar; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
>> wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Nishant Sarmukadam
>> Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station
>> ioctl file
>>
>> Hello Kalle,
>>
>> On 06/10/2016 10:30 AM, Kalle Valo wrote:
>>> Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> writes:
>>>
>>>> From: Shengzhen Li <szli-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>>>>
>>>> Most cfg80211 operations are just a wrappers to functions defined in
>>>> the sta_ioctl.c file, so for consistency move the .get_tx_power logic
>> there.
>>>>
>>>> Signed-off-by: Shengzhen Li <szli-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>>>> Signed-off-by: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
>>>> [javier: update the subject line and commit message]
>>>> Signed-off-by: Javier Martinez Canillas <javier-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
>>>
>>> [...]
>>>
>>>> --- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
>>>> +++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
>>>> @@ -385,18 +385,10 @@ mwifiex_cfg80211_get_tx_power(struct wiphy
>> *wiphy,
>>>>  			      int *dbm)
>>>>  {
>>>>  	struct mwifiex_adapter *adapter =
>> mwifiex_cfg80211_get_adapter(wiphy);
>>>> -	struct mwifiex_private *priv = mwifiex_get_priv(adapter,
>>>> -							MWIFIEX_BSS_ROLE_ANY);
>>>> -	int ret = mwifiex_send_cmd(priv, HostCmd_CMD_RF_TX_PWR,
>>>> -				   HostCmd_ACT_GEN_GET, 0, NULL, true);
>>>> -
>>>> -	if (ret < 0)
>>>> -		return ret;
>>>> -
>>>> -	/* tx_power_level is set in HostCmd_CMD_RF_TX_PWR command handler
>> */
>>>> -	*dbm = priv->tx_power_level;
>>>> +	struct mwifiex_private *priv;
>>>>
>>>> -	return 0;
>>>> +	priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
>>>> +	return mwifiex_get_tx_power(priv, dbm);
>>>>  }
>>>
>>> So in patch 1 you added the patch and in patch 2 you move it to a
>>> different location? That doesn't make any sense, can't you just fold
>>> the two patches into one so that the function is added only once.
>>>
>>
>> I posted this patch in v1 but then Amitkumar shared his patch with me
>> that was very similar to mine, only that the logic was in a different
>> location.
>>
>> So I included his delta as a separate patch to try keeping attribution
>> as best as possible.
>>
> 
> This patch (2/3) is only for code rearrangement and adds an unnecessary wrapper function. We can simply drop the patch.
>

Agreed.

Kalle,

Patch 3/3 applies cleanly even after dropping patch 2/3.
Is that Ok for you or do you want me to re-resend a v3
with only patches 1/3 and 3/3?

> Regards,
> Amitkumar
> 

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
