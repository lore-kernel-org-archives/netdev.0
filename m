From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git)] stmmac: ptp: fix the reference clock
Date: Thu, 28 Aug 2014 08:02:10 +0200
Message-ID: <53FEC5E2.9020708@st.com>
References: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com> <20140827.162652.544817209778584023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:34096 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbaH1GCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:02:20 -0400
In-Reply-To: <20140827.162652.544817209778584023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On 8/28/2014 1:26 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Tue, 26 Aug 2014 08:04:32 +0200
>
>> @@ -638,6 +638,15 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
>>   	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
>>   		return -EOPNOTSUPP;
>>
>> +	/* Fall-back to main clock in case of no PTP ref is passed */
>> +	priv->clk_ptp_ref = devm_clk_get(priv->device, "clk_ptp_ref");
>> +	if (IS_ERR(priv->clk_ptp_ref)) {
>> +		priv->clk_ptp_rate = clk_get_rate(priv->stmmac_clk);
>
> This code path will leave an IS_ERR() value in clk_ptp_ref.
>   ...
>>   static void stmmac_release_ptp(struct stmmac_priv *priv)
>>   {
>> +	if (priv->clk_ptp_ref)
>> +		clk_disable_unprepare(priv->clk_ptp_ref);
>>   	stmmac_ptp_unregister(priv);
>>   }
>
> Which this code will erroneously pass into clk_disable_unprepare().
>
> Please NULL the pointer out properl when devm_clk_get() errors.

I had sent the v2, let me know if it's ok for you.

peppe

>
> Thanks.
>
