From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Configure IMP port TC2QOS
 mapping
Date: Sat, 2 Sep 2017 10:57:26 -0700
Message-ID: <bd44fa58-ad75-246d-0fe9-d6228fbf85b9@gmail.com>
References: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
 <1504310354-42773-5-git-send-email-f.fainelli@gmail.com>
 <20170902163057.GB5463@lunn.ch>
 <e0d92f15-342d-2b5b-2f7d-aedba328116f@gmail.com>
 <20170902174753.GA8981@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35487 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752709AbdIBR5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 13:57:30 -0400
Received: by mail-oi0-f66.google.com with SMTP id n18so2404669oig.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 10:57:30 -0700 (PDT)
In-Reply-To: <20170902174753.GA8981@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/02/2017 10:47 AM, Andrew Lunn wrote:
> On Sat, Sep 02, 2017 at 09:32:08AM -0700, Florian Fainelli wrote:
>>
>>
>> On 09/02/2017 09:30 AM, Andrew Lunn wrote:
>>>> @@ -129,6 +130,14 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
>>>>  	reg |= MII_DUMB_FWDG_EN;
>>>>  	core_writel(priv, reg, CORE_SWITCH_CTRL);
>>>>  
>>>> +	/* Configure Traffic Class to QoS mapping, allow each priority to map
>>>> +	 * to a different queue number
>>>> +	 */
>>>> +	reg = core_readl(priv, CORE_PORT_TC2_QOS_MAP_PORT(port));
>>>> +	for (i = 0; i < 8; i++)
>>>> +		reg |= i << (PRT_TO_QID_SHIFT * i);
>>>
>>> Hi Florian
>>>
>>> Rather than 8, would ds->num_tx_queues be more descriptive?
>>
>> I actually have a patch on top of this which defines a constant for the
>> number of queues instead of open coding 8 here. Thanks!
> 
> Hi Florian
> 
> It sounds like it should be part of 3/4?

Right, let me re-submit with that change included. Thanks
-- 
Florian
