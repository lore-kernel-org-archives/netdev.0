From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH v2 2/3] mwifiex: move .get_tx_power logic to station ioctl
 file
Date: Fri, 10 Jun 2016 10:37:24 -0400
Message-ID: <12ccd90e-e3eb-ecac-b23f-8124b0db32ad@osg.samsung.com>
References: <1465232558-31678-1-git-send-email-javier@osg.samsung.com>
 <1465232558-31678-3-git-send-email-javier@osg.samsung.com>
 <87wplxdsln.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Julian Calaby <julian.calaby@gmail.com>,
	Shengzhen Li <szli@marvell.com>,
	Enric Balletbo i Serra <enric.balletbo@collabora.com>,
	Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wplxdsln.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Kalle,

On 06/10/2016 10:30 AM, Kalle Valo wrote:
> Javier Martinez Canillas <javier@osg.samsung.com> writes:
> 
>> From: Shengzhen Li <szli@marvell.com>
>>
>> Most cfg80211 operations are just a wrappers to functions defined in the
>> sta_ioctl.c file, so for consistency move the .get_tx_power logic there.
>>
>> Signed-off-by: Shengzhen Li <szli@marvell.com>
>> Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
>> [javier: update the subject line and commit message]
>> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> 
> [...]
> 
>> --- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
>> +++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
>> @@ -385,18 +385,10 @@ mwifiex_cfg80211_get_tx_power(struct wiphy *wiphy,
>>  			      int *dbm)
>>  {
>>  	struct mwifiex_adapter *adapter = mwifiex_cfg80211_get_adapter(wiphy);
>> -	struct mwifiex_private *priv = mwifiex_get_priv(adapter,
>> -							MWIFIEX_BSS_ROLE_ANY);
>> -	int ret = mwifiex_send_cmd(priv, HostCmd_CMD_RF_TX_PWR,
>> -				   HostCmd_ACT_GEN_GET, 0, NULL, true);
>> -
>> -	if (ret < 0)
>> -		return ret;
>> -
>> -	/* tx_power_level is set in HostCmd_CMD_RF_TX_PWR command handler */
>> -	*dbm = priv->tx_power_level;
>> +	struct mwifiex_private *priv;
>>  
>> -	return 0;
>> +	priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
>> +	return mwifiex_get_tx_power(priv, dbm);
>>  }
> 
> So in patch 1 you added the patch and in patch 2 you move it to a
> different location? That doesn't make any sense, can't you just fold the
> two patches into one so that the function is added only once.
>

I posted this patch in v1 but then Amitkumar shared his patch with me that
was very similar to mine, only that the logic was in a different location.

So I included his delta as a separate patch to try keeping attribution as
best as possible.

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
