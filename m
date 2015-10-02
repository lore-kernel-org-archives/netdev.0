From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Fri, 2 Oct 2015 15:30:29 +0200
Message-ID: <560E86F5.2030301@baylibre.com>
References: <560E60E4.8020706@baylibre.com>
 <560E86BC.3090104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560E86BC.3090104@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2015 03:29 PM, Sergei Shtylyov wrote:
> On 10/2/2015 1:48 PM, Neil Armstrong wrote:
> 
>> To simplify and prevent memory leakage when unbinding, use
>> the devm_ memory allocation calls.
>>
>> Tested-by: Andrew Lunn <andrew@lunn.ch>
>> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>>   net/dsa/dsa.c | 6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
>> index c59fa5d..98f94c2 100644
>> --- a/net/dsa/dsa.c
>> +++ b/net/dsa/dsa.c
>> @@ -305,7 +305,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>>       if (ret < 0)
>>           goto out;
>>
>> -    ds->slave_mii_bus = mdiobus_alloc();
>> +    ds->slave_mii_bus = devm_mdiobus_alloc(parent);
>>       if (ds->slave_mii_bus == NULL) {
>>           ret = -ENOMEM;
>>           goto out;
>> @@ -400,7 +400,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>>       /*
>>        * Allocate and initialise switch state.
>>        */
>> -    ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
>> +    ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
>>       if (ds == NULL)
>>           return ERR_PTR(-ENOMEM);
>>
>> @@ -883,7 +883,7 @@ static int dsa_probe(struct platform_device *pdev)
>>           goto out;
>>       }
>>
>> -    dst = kzalloc(sizeof(*dst), GFP_KERNEL);
>> +    dst = devm_kzalloc(&pdev->dev, sizeof(*dst), GFP_KERNEL);
>>       if (dst == NULL) {
>>           dev_put(dev);
>>           ret = -ENOMEM;
>>
> 
>    Shouldn't you remove the correspoding kfree(), etc. calls?
> 
> MBR, Sergei
> 
The corresponding kfree() calls were all missing.

Neil
