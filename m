From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/10] stmmac: sanitize the rx coe and add the type-1
 csum
Date: Mon, 02 Apr 2012 13:07:38 +0200
Message-ID: <4F79887A.50804@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com> <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com> <4F6D921F.10400@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	spear-devel <spear-devel@list.st.com>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Viresh KUMAR <viresh.kumar@st.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:47225 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752184Ab2DBLJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 07:09:10 -0400
In-Reply-To: <4F6D921F.10400@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/2012 10:21 AM, Deepak SIKRI wrote:
> 
> 
> 
> On 3/23/2012 2:38 PM, Giuseppe CAVALLARO wrote:
>> [snip]
>>
>>
>> -    priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
>> -    if (priv->rx_coe)
>> -        pr_info(" RX Checksum Offload Engine supported\n");
>> +    if (priv->plat->rx_coe)
>> +        pr_info(" RX Checksum Offload Engine supported (type %d)\n",
>> +            priv->plat->rx_coe);
>>       if (priv->plat->tx_coe)
>>           pr_info(" TX Checksum insertion supported\n");
>>
> 
> rx_coe needs to be enabled. Earlier it was being done. Any specific
> reasons to remove this.
> Instead this code needs to be moved post mac reset has been done.

Hello Deepak

sorry for this delay.

I've not clear at all your question.
The driver well uses the rx_coe as briefly described below:

probe funct
  |__ hw_init
         |_ check the RX type from HW cap reg
                 |__ Override the rx_coe if required

After that the rx_coe is used and passed to the core as expected.
In case of there is no HW cap register so the rx_coe from platform will
be used.

Peppe

> 
> Regards
> Deepak
> 
