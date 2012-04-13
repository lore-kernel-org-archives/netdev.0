From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 3/4 (V3)] stmmac: add the Energy Efficient Ethernet
 support
Date: Fri, 13 Apr 2012 08:35:26 +0200
Message-ID: <4F87C92E.7040503@st.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com> <1333704559-11251-4-git-send-email-peppe.cavallaro@st.com> <20120412.163258.602029261264172098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:36634 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754539Ab2DMGhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 02:37:00 -0400
In-Reply-To: <20120412.163258.602029261264172098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/2012 10:32 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Fri,  6 Apr 2012 11:29:17 +0200
> 
>> +static int stmmac_ethtool_op_set_eee(struct net_device *dev,
>> +				     struct ethtool_value *eee)
>> +{
>> +	struct stmmac_priv *priv = netdev_priv(dev);
>> +
>> +	if ((!eee->data) && (priv->eee_enabled)) {
>> +		stmmac_disable_eee_mode(priv);
>> +		priv->eee_enabled = eee->data;
>> +	} else if ((eee->data) && (!priv->eee_enabled))
>> +		/* We are asking for enabling the EEE but this
>> +		 * has to be verified by invoking the eee_init function.
>> +		 * For this reason we cannot set eee_enabled to
>> +		 * eee->data, directly. */
>> +		priv->eee_enabled = stmmac_eee_init(priv);
>> +
>> +	return 0;
> 
> If stmmac_eee_init() determines that it cannot enable eee, you should
> return an appropriate error code here so that ethtool can report that
> fact.

Ok, thanks

peppe
