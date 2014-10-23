From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 11/14] net: dsa: Add support for reading switch registers
 with ethtool
Date: Wed, 22 Oct 2014 22:21:29 -0700
Message-ID: <54489059.8010606@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-12-git-send-email-linux@roeck-us.net> <CAGVrzcbfkSK58iCPouMc4g8MBrAPBemi8QyP6_33xtYiRWFCHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcbfkSK58iCPouMc4g8MBrAPBemi8QyP6_33xtYiRWFCHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2014 09:40 PM, Florian Fainelli wrote:
> 2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
>> Add support for reading switch registers with 'ethtool -d'.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>
> [snip]
>
>>
>> +static int dsa_slave_get_regs_len(struct net_device *dev)
>> +{
>> +       struct dsa_slave_priv *p = netdev_priv(dev);
>> +       struct dsa_switch *ds = p->parent;
>> +
>> +       if (ds->drv->get_regs_len != NULL)
>> +               return ds->drv->get_regs_len(ds, p->port);
>
> Most of the checks in this file are just:
>
> if (ds->drv->callback)
>       return ds->drv->callback(...)
>
Hi Florian,

To be fair, that wasn't the case when I wrote the code ;-).
No problem, I'll do the same.

>> +
>> +       return -EOPNOTSUPP;
>> +}
>> +
>> +static void
>> +dsa_slave_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
>> +{
>> +       struct dsa_slave_priv *p = netdev_priv(dev);
>> +       struct dsa_switch *ds = p->parent;
>> +
>> +       ds->drv->get_regs(ds, p->port, regs, _p);
>
> We need to check that the driver does implement this callback here as well.
>

Obviously, and embarrassing ;-).

Thanks a lot for the review!
Guenter
