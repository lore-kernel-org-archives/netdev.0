From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] mdio: mux: fix device_node_continue.cocci warnings
Date: Fri, 12 May 2017 15:52:25 -0700
Message-ID: <872f3980-9faa-718f-3260-9e4b22946140@gmail.com>
References: <alpine.DEB.2.20.1705122252440.3416@hadrien>
 <20170512.122223.341607427763777325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.mason@broadcom.com, andrew@lunn.ch,
        kbuild-all@01.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, julia.lawall@lip6.fr,
        jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512.122223.341607427763777325.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/12/2017 09:22 AM, David Miller wrote:
> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Fri, 12 May 2017 22:54:23 +0800 (SGT)
> 
>> Device node iterators put the previous value of the index variable, so an
>> explicit put causes a double put.
>  ...
>> @@ -169,7 +169,6 @@ int mdio_mux_init(struct device *dev,
>>  		if (r) {
>>  			mdiobus_free(cb->mii_bus);
>>  			devm_kfree(dev, cb);
>> -			of_node_put(child_bus_node);
>>  		} else {
> 
> I think we're instead simply missing a break; statement here.

It's kind of questionable, if we have an error initializing one of our
child MDIO bus controller (child from the perspective of the MDIO mux,
boy this is getting complicated...), should we keep on going, or should
we abort entirely and rollback what we have successfully registered?

I don't think Julia's patch makes thing worse, in that if we had to
rollback, we would not be doing this correctly now anyway.

Jon, what do you think?
-- 
Florian
