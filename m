From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/6] stmmac: Add support for CPU freq notifiers.
Date: Tue, 06 Mar 2012 09:04:14 +0100
Message-ID: <4F55C4FE.7010607@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <4F54D62B.2080502@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org
To: Deepak Sikri <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:47525 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758261Ab2CFIFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:05:09 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D5B9A192
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 08:05:06 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6A1591721
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 08:05:06 +0000 (GMT)
In-Reply-To: <4F54D62B.2080502@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/2012 4:05 PM, Giuseppe CAVALLARO wrote:
[snip]
>> +#ifdef CONFIG_CPU_FREQ
>> +static inline void stmmac_clk_csr_set(struct stmmac_priv *priv, int clk_rate)
>> +{
>> +
>> +	if ((clk_rate >= CSR_F_20M) && (clk_rate < CSR_F_35M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_20_35M;
>> +	else if ((clk_rate >= CSR_F_35M) && (clk_rate < CSR_F_60M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_35_60M;
>> +	else if ((clk_rate >= CSR_F_60M) && (clk_rate < CSR_F_100M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_60_100M;
>> +	else if ((clk_rate >= CSR_F_100M) && (clk_rate < CSR_F_150M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_100_150M;
>> +	else if ((clk_rate >= CSR_F_150M) && (clk_rate < CSR_F_250M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;
>> +	else if ((clk_rate >= CSR_F_250M) && (clk_rate < CSR_F_300M))
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_250_300M;
>> +	else
>> +		priv->plat->clk_csr = STMMAC_CLK_RANGE_150_250M;


Another note is that you are overriding the priv->plat->clk_csr that was
passed through the platform and used in some case on other architectures.

peppe
