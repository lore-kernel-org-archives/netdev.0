From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 16 Oct 2015 13:24:16 -0700
Message-ID: <56215CF0.6080905@caviumnetworks.com>
References: <56201158.8040806@opensource.altera.com> <56201AE7.2020103@gmail.com> <alpine.DEB.2.02.1510152102280.22844@linux-builds1> <20151016033143.GA28207@lunn.ch> <alpine.DEB.2.02.1510160935310.22648@linux-builds1> <20151016150345.GI10146@lunn.ch> <alpine.DEB.2.02.1510161027590.16637@linux-builds1> <20151016155644.GJ10146@lunn.ch> <56212A09.5080206@caviumnetworks.com> <alpine.DEB.2.02.1510161407570.22838@linux-builds1> <20151016193854.GC28207@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151016193854.GC28207@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2015 12:38 PM, Andrew Lunn wrote:
>>> Maybe we need to walk up the hierarchy.
>>>
>>> Perhaps something like:
>>>
>>> const struct device *dev_walker;
>>>
>>> dev_walker = &phydev->dev;
>>> do {
>>>     of_node = dev_walker->of_node;
>>>     dev_walker = dev_walker->parent;
>>> } while (!of_node && dev_walker);
>>>
>>
>> The above code seems to have fixed the issue.
>
> What i don't like about this is that it allows you to put these
> properties in the mdio device node. These are phy properties, not mdio
> properties....

Yes, we know that the device tree is not correctly formed.

You have a choice:

A) Fix the device tree and any code that may have to change to work with 
a good device tree.

B) Change the code to work with the screwy existing device tree.  The 
above seems to work, other things may also be possible.

I can't really make any decisions as to what the best way to proceed is, 
as I neither have the hardware in question, nor the time to work on it.

David Daney

>
> If phydev->attached_dev->dev->of_node works, that would be my
> preference.
>
>         Andrew
>
