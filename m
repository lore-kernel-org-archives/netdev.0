From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] stmmac: fix check for phydev being open
Date: Tue, 8 Sep 2015 22:53:51 +0300
Message-ID: <55EF3CCF.4000608@cogentembedded.com>
References: <1441701786-10789-1-git-send-email-abrodkin@synopsys.com>
 <55EEC462.2000906@cogentembedded.com> <1441716387.21150.0.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:33334 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbbIHTxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 15:53:55 -0400
Received: by lamp12 with SMTP id p12so74618043lam.0
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 12:53:54 -0700 (PDT)
In-Reply-To: <1441716387.21150.0.camel@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/08/2015 03:46 PM, Alexey Brodkin wrote:

>>> Current check of phydev with IS_ERR(phydev) may make not much sense
>>> because of_phy_connect() returns NULL on failure instead of error value.
>>>
>>> Still for checking result of phy_connect() IS_ERR() makes perfect sense.
>>>
>>> So let's use combined check IS_ERR_OR_NULL() that covers both cases.
>>>
>>> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>> Cc: linux-kernel@vger.kernel.org
>>> Cc: stable@vger.kernel.org
>>> Cc: David Miller <davem@davemloft.net>
>>> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
>>> ---
>>>
>>> Changes compared to v2:
>>>    * Updated commit message with mention of of_phy_connect() instead of
>>>      of_phy_attach().
>>>    * Return ENODEV in case of of_phy_connect() failure
>>>
>>> Changes compared to v1:
>>>    * Use IS_ERR_OR_NULL() instead of discrete checks for null and err
>>>
>>>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 +++++--
>>>    1 file changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index 864b476..e2c9c86 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -837,9 +837,12 @@ static int stmmac_init_phy(struct net_device *dev)
>>>    				     interface);
>>>    	}
>>>
>>> -	if (IS_ERR(phydev)) {
>>> +	if (IS_ERR_OR_NULL(phydev)) {
>>>    		pr_err("%s: Could not attach to PHY\n", dev->name);
>>> -		return PTR_ERR(phydev);
>>> +		if (!phydev)
>>> +			return -ENODEV;
>>> +		else
>>> +			return PTR_ERR(phydev);
>>
>>      Don't need *else* after *return* and scripts/checkpatch.pl should have
>> complained about that.
>
> ./scripts/checkpatch.pl 0001-stmmac-fix-check-for-phydev-being-open.patch
> total: 0 errors, 0 warnings, 0 checks, 14 lines checked

    Hm... I bet I saw such warning from checkpatch.pl recently (it was a false 
positive though, so maybe the check was removed recently, not sure). Your 
patch is clean indeed, however my comment is still valid.

> -Alexey

MBR, Sergei
