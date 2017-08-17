From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 1/4] can: dev: Add support for limiting configured
 bitrate
Date: Thu, 17 Aug 2017 21:09:43 +0300
Message-ID: <c6f5667d-f5c0-956d-7067-87a4de0d79c7@cogentembedded.com>
References: <20170810005916.27163-1-fcooper@ti.com>
 <20170810005916.27163-2-fcooper@ti.com>
 <9a6f4fdf-a4f6-283b-0e5a-693cc7d263ef@cogentembedded.com>
 <b1082666-6cdf-374e-2c83-8d520e0996ad@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        andrew@lunn.ch, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <b1082666-6cdf-374e-2c83-8d520e0996ad@ti.com>
Content-Language: en-MW
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 08/17/2017 08:54 PM, Franklin S Cooper Jr wrote:

>>> Various CAN or CAN-FD IP may be able to run at a faster rate than
>>> what the transceiver the CAN node is connected to. This can lead to
>>> unexpected errors. However, CAN transceivers typically have fixed
>>> limitations and provide no means to discover these limitations at
>>> runtime. Therefore, add support for a can-transceiver node that
>>> can be reused by other CAN peripheral drivers to determine for both
>>> CAN and CAN-FD what the max bitrate that can be used. If the user
>>> tries to configure CAN to pass these maximum bitrates it will throw
>>> an error.
>>>
>>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
>>> ---
>>> Version 4 changes:
>>> Used can-transceiver instead of fixed-transceiver.
>>>
>>>    drivers/net/can/dev.c   | 50
>>> +++++++++++++++++++++++++++++++++++++++++++++++++
>>>    include/linux/can/dev.h |  5 +++++
>>>    2 files changed, 55 insertions(+)
>>>
>>> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
>>> index 365a8cc..372108f 100644
>>> --- a/drivers/net/can/dev.c
>>> +++ b/drivers/net/can/dev.c
>> [...]
>>> @@ -814,6 +815,39 @@ int open_candev(struct net_device *dev)
>>>    }
>>>    EXPORT_SYMBOL_GPL(open_candev);
>>>    +#ifdef CONFIG_OF
>>> +/*
>>> + * Common function that can be used to understand the limitation of
>>> + * a transceiver when it provides no means to determine these
>>> limitations
>>> + * at runtime.
>>> + */
>>> +void of_can_transceiver(struct net_device *dev)
>>> +{
>>> +    struct device_node *dn;
>>> +    struct can_priv *priv = netdev_priv(dev);
>>> +    struct device_node *np;
>>> +    unsigned int max_bitrate;
>>> +    int ret;
>>> +
>>> +    np = dev->dev.parent->of_node;
>>
>>     I'd do that as an initializer.
> 
> Ok
>>
>>> +
>>> +    dn = of_get_child_by_name(np, "can-transceiver");
>>> +    if (!dn)
>>> +        return;
>>> +
>>> +    max_bitrate = 0;
>>> +    ret = of_property_read_u32(dn, "max-bitrate", &max_bitrate);
>>
>>     I'd initialize max_bitrate to 0 as iff of_property_read_u32() fails,
>> it'll leave the variable unset...>
>>> +
>>> +    if (max_bitrate > 0) {
>>
>>     You risk checking unset variable here.
> 
> Four lines up I am already setting max_bitrate to a default value of 0.

    Oops, sorry. Don't know how I missed that. Better done as initializer too 
though...

MBR, Sergei
