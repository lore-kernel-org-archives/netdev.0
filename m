From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 4/9] stmmac: add MMC support exported via ethtool (v2)
Date: Fri, 02 Sep 2011 08:48:54 +0200
Message-ID: <4E607C56.30305@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>  <1314714064-29101-5-git-send-email-peppe.cavallaro@st.com> <1314718004.2752.15.camel@bwh-desktop> <4E5DCC28.90201@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:54247 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255Ab1IBGtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 02:49:16 -0400
In-Reply-To: <4E5DCC28.90201@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

any news or other advice?

In that case, I'll resend the patches (v3) with the modifications
suggested by Ben.

Regards
Peppe

On 8/31/2011 7:52 AM, Giuseppe CAVALLARO wrote:
> Hello Ben
> 
> On 8/30/2011 5:26 PM, Ben Hutchings wrote:
>> On Tue, 2011-08-30 at 16:20 +0200, Giuseppe CAVALLARO wrote:
>>> This patch adds the MMC management counters support.
>>> MMC module is an extension of the register address
>>> space and all the hardware counters can be accessed
>>> via ethtoo -S ethX.
>>>
>>> Note that, the MMC interrupts remain masked and the logic
>>> to handle this kind of interrupt will be added later (if
>>> actually useful).
>> [...]
>>>  static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
>>>  				      struct ethtool_drvinfo *info)
>>>  {
>>>  	struct stmmac_priv *priv = netdev_priv(dev);
>>>  
>>> -	if (!priv->plat->has_gmac)
>>> -		strcpy(info->driver, MAC100_ETHTOOL_NAME);
>>> -	else
>>> +	info->n_stats = STMMAC_STATS_LEN;
>>> +
>>> +	if (likely(priv->plat->has_gmac)) {
>>
>> Using likely() and unlikely() in ethtool operations seems like a
>> pointless optimisation.
> 
> I agree with you that ethtool part is not critical and likely/unlikely
> could be not used at all.
> 
> I had added them because today, AFAIK, the driver works on several
> platforms with the GMAC and continues to support MAC10/100 (that I test
> in my lab). I had thought that the likely/unlikely in ethtool can help
> to emit instructions that causes optimize branch prediction to favor the
> "likely" GMAC side.
> 
> At any rate, no problem to rework the patch deleting them or create a
> new one on top of these.
> 
>>
>>>  		strcpy(info->driver, GMAC_ETHTOOL_NAME);
>>> +		info->n_stats += STMMAC_MMC_STATS_LEN;
>>> +	} else
>>> +		strcpy(info->driver, MAC100_ETHTOOL_NAME);
>>>  
>>>  	strcpy(info->version, DRV_MODULE_VERSION);
>>>  	info->fw_version[0] = '\0';
>>> -	info->n_stats = STMMAC_STATS_LEN;
>>>  }
>> [...]
>>
>> Don't bother initialising ethtool_drvinfo::n_stats.  The ethtool core
>> will do it by calling your get_sset_count implementation.
> 
> Ok! thanks I missed this.
> 
> As above, let me know if I have to resent the patches or create a new
> patch for this fix too.
> 
> In the end, any other advice?
> 
> Regards
> Peppe
>>
>> Ben.
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
