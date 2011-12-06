From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Tue, 06 Dec 2011 07:44:25 -0500
Message-ID: <4EDE0E29.9070809@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>   <20111026.194045.2019668159403582571.davem@davemloft.net>   <4EA8B283.3010105@teksavvy.com>   <20111026.221719.2216112919297458522.davem@davemloft.net>   <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>   <4EBAA967.10403@teksavvy.com> <1320856444.18929.78.camel@deadeye>   <4EBAAEA5.1060408@teksavvy.com> <4EBAB0EA.1050102@teksavvy.com>   <4EBAB643.8020603@teksavvy.com> <1320859911.2781.1.camel@bwh-desktop>   <4EBABAFD.6050604@teksavvy.com> <1320860895.2781.6.camel@bwh-desktop>  <4EDCD828.2090904@teksavvy.com> <1323098335.7454.214.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323098335.7454.214.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-12-05 10:18 AM, Ben Hutchings wrote:
> On Mon, 2011-12-05 at 09:41 -0500, Mark Lord wrote:
> [...]
>> static int ax88772b_bind(struct usbnet *dev, struct usb_interface *intf)
>> {
>> ...
>>         /* register support for hardware checksums */
>>         dev->net->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
>>
>>         /* enable hardware checksums */
>>         dev->net->features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
>>         ax88772b_set_features(dev->net, dev->net->features);
>> ...
>> }
>> -------------------------------snip-----------------------------------
>>
>> Does this look correct -- any improvements/fixes to suggest?
> [...]
> 
> NETIF_F_HW_CSUM means the hardware implements generic IP-style
> checksumming: the stack specifies the offset at which to start
> checksumming and the offset at which to store the checksum, and the
> hardware does not attempt to parse the headers.
> 
> If this hardware recognises specific protocols and works out the offsets
> itself, then you must claim NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM instead.

Yeah, the hardware seems to understand quite a few protocol formats.
Okay, so I'll claim the protocol-specific flags in net->hw_features.

But what do I use in net->features?
The exact same protocol flags,
or the generic NETIF_F_HW_CSUM | NETIF_F_RXCSUM ones?

The set_features() function also has to test for flags
to know what to do.  Should it test specific protocol flags,
or just the generic two ?

Thanks!
