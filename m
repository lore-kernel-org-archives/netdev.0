From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: dsa: Add support for platform data
Date: Tue, 10 Jan 2017 13:06:07 -0800
Message-ID: <1530c7f6-f8ba-ab32-75aa-288549f25db9@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
 <20170110201235.21771-7-f.fainelli@gmail.com>
 <20170110204124.GL22820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110204124.GL22820@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2017 12:41 PM, Andrew Lunn wrote:
>> @@ -452,11 +455,14 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
>>  	struct net_device *ethernet_dev;
>>  	struct device_node *ethernet;
>>  
>> -	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
>> -	if (!ethernet)
>> -		return -EINVAL;
>> +	if (port->dn) {
>> +		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
>> +		if (!ethernet)
>> +			return -EINVAL;
>> +		ethernet_dev = of_find_net_device_by_node(ethernet);
>> +	} else
>> +		ethernet_dev = dev_to_net_device(dst->pd->netdev);

Bonjour Andrew,

> 
> Hi Florian
> 
> This is not going to work with John's rework of my multi CPU ports
> code. I think you are going to have to modify the platform_data
> structure to support multi-CPU ports.

Last time we discussed this, I had a super complex dsa2_platform_data
that allowed you to do exactly the same thing we currently do with
Device Tree, except that this was with platform_data. It took a lot of
effort to get there, but I essentially had the ZII vf160 board example
re-implemented and verified with a mockup driver (still have it in a
branch that's not too far from net-next/master).

Your reply then AFAIR was that we should aim for something simpler and
here is the result, we end-up re-using the existing dsa_platform_data
with its limitations.

If we have legacy platforms with complex setups, I really don't think we
have those in tree, we should use dsa2_platform_data (still have the
patches somewhere for that) although I was hoping to not have to use it
since it is way more intrusive into net/dsa/dsa2.c.

All platforms that I know that will benefit from this patch series: x86
SCU from ZII (out of tree), BCM47xx, BCM63xx, Orion5x have the same
properties: single switch attached to a SPI/MDIO/MMAP with built-in
PHYs. If we have more complex setups than that, we should try to collect
the requirements.

> 
> I put higher priority on cleanly integrating multi-CPU ports using
> device tree, than supporting legacy platforms. I'm O.K. with
> preparatory patches, but i think we should wait for actually platform
> data changes until after Johns code has landed and we can design the
> platform_data to work with it.

I would very much like to see the patches and then make a decision based
on the submission rather than project a decision on code that has not
been submitted yet.

Do we agree that patches 1 through 5 and 7 could go in then?
-- 
Florian
