From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [BISECTED] v4.9: OCTEON ethernet crash
Date: Wed, 14 Dec 2016 17:14:04 -0800
Message-ID: <2c346015-958a-3f65-f877-8b6fc21165f6@gmail.com>
References: <20161215003253.un6hk2ytl3auiztn@raspberrypi-2.musicnaut.iki.fi>
 <f70acf45-191d-215a-0019-420627a35d98@gmail.com>
 <20161215005751.457nm46shyjdt63q@raspberrypi-2.musicnaut.iki.fi>
 <4ca48a84-c041-d698-e55b-0c8da0fc4140@gmail.com>
 <20161215011203.nyyl5izlzkqtium5@raspberrypi-2.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        David Daney <ddaney@caviumnetworks.com>, netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36368 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757149AbcLOBOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 20:14:08 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so4124004pgx.3
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 17:14:07 -0800 (PST)
In-Reply-To: <20161215011203.nyyl5izlzkqtium5@raspberrypi-2.musicnaut.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2016 05:12 PM, Aaro Koskinen wrote:
> Hi,
> 
> On Wed, Dec 14, 2016 at 05:00:59PM -0800, Florian Fainelli wrote:
>> On 12/14/2016 04:57 PM, Aaro Koskinen wrote:
>>> On Wed, Dec 14, 2016 at 04:41:13PM -0800, Florian Fainelli wrote:
>>>> On 12/14/2016 04:32 PM, Aaro Koskinen wrote:
>>>>> Git bisect points to:
>>>>>
>>>>> commit ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461
>>>>> Author: Florian Fainelli <f.fainelli@gmail.com>
>>>>> Date:   Tue Dec 6 20:54:43 2016 -0800
>>>>>
>>>>>     phy: Don't increment MDIO bus refcount unless it's a different owner
>>>>>
>>>>> Reverting this patch from v4.9 fixes the issue...
>>>>
>>>> This should help:
>>>>
>>>> diff --git a/drivers/staging/octeon/ethernet.c
>>>> b/drivers/staging/octeon/ethernet.c
>>>> index 8130dfe89745..12ebc4d800c3 100644
>>>> --- a/drivers/staging/octeon/ethernet.c
>>>> +++ b/drivers/staging/octeon/ethernet.c
>>>> @@ -770,6 +770,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
>>>>                         /* Initialize the device private structure. */
>>>>                         struct octeon_ethernet *priv = netdev_priv(dev);
>>>>
>>>> +                       SET_NETDEV_DEV(dev, &pdev->dev);
>>>>                         dev->netdev_ops = &cvm_oct_pow_netdev_ops;
>>>>                         priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
>>>>                         priv->port = CVMX_PIP_NUM_INPUT_PORTS;
>>>
>>> No, it's still crashing.
>>
>> How about this:
>>
>> diff --git a/drivers/staging/octeon/ethernet.c
>> b/drivers/staging/octeon/ethernet.c
>> index 12ebc4d800c3..4971aa54756a 100644
>> --- a/drivers/staging/octeon/ethernet.c
>> +++ b/drivers/staging/octeon/ethernet.c
>> @@ -817,6 +817,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
>>                         }
>>
>>                         /* Initialize the device private structure. */
>> +                       SET_NETDEV_DEV(dev, &pdev->dev);
>>                         priv = netdev_priv(dev);
>>                         priv->netdev = dev;
>>                         priv->of_node = cvm_oct_node_for_port(pip,
>> interface,
> 
> Yeah, that seems to work - thanks! Could you send this to
> devel@driverdev.osuosl.org as a formal patch?

Sure thing, thanks for verifying it. Sent.
-- 
Florian
