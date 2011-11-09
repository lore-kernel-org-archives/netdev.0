From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 09 Nov 2011 12:40:13 -0500
Message-ID: <4EBABAFD.6050604@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>  <20111026.194045.2019668159403582571.davem@davemloft.net>  <4EA8B283.3010105@teksavvy.com>  <20111026.221719.2216112919297458522.davem@davemloft.net>  <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>  <4EBAA967.10403@teksavvy.com> <1320856444.18929.78.camel@deadeye>  <4EBAAEA5.1060408@teksavvy.com> <4EBAB0EA.1050102@teksavvy.com>  <4EBAB643.8020603@teksavvy.com> <1320859911.2781.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320859911.2781.1.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 12:31 PM, Ben Hutchings wrote:
> On Wed, 2011-11-09 at 12:20 -0500, Mark Lord wrote:
>> On 11-11-09 11:57 AM, Mark Lord wrote:
>>> On 11-11-09 11:47 AM, Mark Lord wrote:
>>> ..
>>>> Note:  I'm looking at smsc95xx.c and smsc75xx.c for examples,
>>>> and they both have the same problem I'll have here:
>>>>
>>>> How to update the csum settings atomically.
>>>> A spinlock is no good, because config register access is over USB.
>>>
>>> Nevermind.. a slight change in the logic and all is well again.
>> ..
>>
>> Or even simpler (below).  I don't think this method requires any
>> extra locking, but I'm still open to persuasion.  :)
> 
> Looks reasonable, but...
> 
>> static int ax88772b_set_features(struct net_device *netdev, u32 features)
>> {
>>         struct usbnet *dev = netdev_priv(netdev);
>>         struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
>>         u16 tx_csum = 0, rx_csum = 0;
>>
>>         priv->features = features & (NETIF_F_HW_CSUM | NETIF_F_RXCSUM);
> 
> ...why do you need priv->features at all?


There's code elsewhere that takes action under some conditions
based on the current setting of the NETIF_F_RXCSUM flag.

I don't claim to fully understand what's going on,
but it doesn't care much about races on set/clear of the flag.

Cheers
