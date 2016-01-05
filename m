From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 04/18] stmmac: remove modulo in stmmac_xmit()
Date: Tue, 5 Jan 2016 09:56:24 +0100
Message-ID: <568B8538.10101@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>	<1451912823-5245-5-git-send-email-peppe.cavallaro@st.com> <20160104.223459.1663440859688328335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>,
	<david.mckay@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:9987 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751094AbcAEI4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 03:56:31 -0500
In-Reply-To: <20160104.223459.1663440859688328335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

On 1/5/2016 4:34 AM, David Miller wrote:
> From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Date: Mon, 4 Jan 2016 14:06:49 +0100
>
>> @@ -2056,7 +2068,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>>   	priv->hw->desc->set_tx_owner(first);
>>   	wmb();
>>
>> -	priv->cur_tx++;
>> +	if (++entry >= txsize)
>> +		entry = 0;
>
> You are doing this over and over again, encapsulate it into a helper
> like "NEXT_TX(x)" or similar.
>
> Also, this is just fundamentally completely stupid.  Enforce the ring

this is not completely gentle but I share the final advice and I will 
fix that asap.

thanks for the review.

peppe

> size to be a power-of-2, then you can just go "x + 1 & (size - 1)" and
> not even have the conditional statement.
>
> Thanks.
>
