From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Wed, 14 Mar 2012 14:16:56 +0100
Message-ID: <4F609A48.6050702@st.com>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <20120312143825.GB13869@game.jcrosoft.org> <4F60832E.6060100@st.com> <201203141307.55808.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	netdev@vger.kernel.org, Stefan Roese <sr@denx.de>,
	devicetree-discuss@ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:56876 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760980Ab2CNNSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 09:18:24 -0400
In-Reply-To: <201203141307.55808.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/2012 2:07 PM, Arnd Bergmann wrote:
> On Wednesday 14 March 2012, Giuseppe CAVALLARO wrote:
>> On 3/12/2012 3:38 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>> On 15:05 Mon 12 Mar     , Stefan Roese wrote:
>>>> This patch adds support to configure the STMMAC ethernet driver via
>>>> device-tree instead of platform_data.
>>>>
>>>> Currently, only the properties needed on SPEAr600 are provided. All
>>>> other properties should be added once needed on other platforms.
>>>>
>>>> Signed-off-by: Stefan Roese <sr@denx.de>
>>>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>>> Cc: Viresh Kumar <viresh.kumar@st.com>
>>>> ---
>>>>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
>>>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66 +++++++++++++++++++-
>>>>  2 files changed, 103 insertions(+), 1 deletion(-)
>>>>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>>>> new file mode 100644
>>>> index 0000000..386a47f
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>>>> @@ -0,0 +1,38 @@
>>>> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
>>>> +
>>>> +Required properties:
>>>> +- compatible: Should be "stm,gmac"
>>
>>> this IP have 2 version at least the GMAC for the second generation and mac for
>>> the first generation
>>
>> yes you are right. STMMAC supports two device generations I named:
>> dwma10/100 and dwmac1000 (gmac).
>>
>> Concerning the latter, we support several different versions of the
>> synopsys GMAC cores ... from 3.30 to 3.61a.
>>
>> For example, stx7108 and Stx7109 have the same GMAC core (also SPEAr600
>> IIRC).
>> SPEAr13xx has 3.50a
>> New ST SoC Stxh415 has the 3.60a. etc.
> 
> In that case, you should definitely list the exact device versions in the
> compatible string, like:
> 
> compatible = "stm,spear600-gmac", "snps,dw-gmac-3.50a", "snps,dw-gmac";

looks good to me

> 
> When we have other socs with the same version, that lets us add quirks
> for the specific version by checking the compatible property once in the
> driver.
> 
> It also sounds to me that the entire stmmac driver should live in the
> drivers/net/ethernet/synopsys directory, not stmicro, but that is a
> different issue.
> 

I had also proposed to rename it from stmmac to synmac.

peppe

> 	Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
