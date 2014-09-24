From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for
 rndis
Date: Wed, 24 Sep 2014 15:12:08 +0200
Message-ID: <5422C328.3000504@denx.de>
References: <1411541339-32400-1-git-send-email-hs@denx.de> <xa1tbnq59x3z.fsf@mina86.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Macpaul Lin <macpaul@gmail.com>
To: Michal Nazarewicz <mina86@mina86.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <xa1tbnq59x3z.fsf@mina86.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michal,

Am 24.09.2014 11:38, schrieb Michal Nazarewicz:
> On Wed, Sep 24 2014, Heiko Schocher<hs@denx.de>  wrote:
>> use the values for RNDIS over Ethernet as defined in
>> http://www.usb.org/developers/defined_class
>> (search for RDNIS):
>>
>> - baseclass: 0xef (miscellaneous)
>> - subclass: 0x04
>> - protocol: 0x01
>>
>> with this setings the file in Documentation/usb/linux.inf is
>> obsolete.
>>
>> Signed-off-by: Heiko Schocher<hs@denx.de>
>>
>> ---
>>
>> Cc: Felipe Balbi<balbi@ti.com>
>> Cc: Greg Kroah-Hartman<gregkh@suse.de>
>> Cc: linux-usb@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: Oliver Neukum<oliver@neukum.name>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-api@vger.kernel.org
>> Cc: Andrzej Pietrasiewicz<andrzej.p@samsung.com>
>> Cc: Michal Nazarewicz<mina86@mina86.com>
>> Cc: Kyungmin Park<kyungmin.park@samsung.com>
>> Cc: Dan Carpenter<dan.carpenter@oracle.com>
>> Cc: Macpaul Lin<macpaul@gmail.com>
>>
>> Tested with the "USB Compliance test suite which runs Windows", see:
>> http://www.usb.org/developers/tools/usb20_tools/#usb20cv
>>
>>   drivers/net/usb/cdc_ether.c           | 6 +++---
>>   drivers/usb/core/generic.c            | 6 +++---
>>   drivers/usb/gadget/function/f_rndis.c | 6 +++---
>>   include/uapi/linux/usb/cdc.h          | 3 +++
>>   4 files changed, 12 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
>> index 2a32d91..9c216c2 100644
>> --- a/drivers/net/usb/cdc_ether.c
>> +++ b/drivers/net/usb/cdc_ether.c
>> @@ -35,9 +35,9 @@
>>
>>   static int is_rndis(struct usb_interface_descriptor *desc)
>>   {
>> -	return (desc->bInterfaceClass == USB_CLASS_COMM&&
>> -		desc->bInterfaceSubClass == 2&&
>> -		desc->bInterfaceProtocol == 0xff);
>> +	return (desc->bInterfaceClass == USB_CLASS_MISC&&
>> +		desc->bInterfaceSubClass == USB_CDC_SUBCLASS_RNDIS&&
>> +		desc->bInterfaceProtocol == USB_CDC_RNDIS_PROTO_ETH);
>>   }
>
> Does that mean that new kernels will stop working with old RNDIs
> gadgets because they stop recognising them as RNDIS?  I feel like this
> function should accept both, i.e.:

Hmm.. I am not a usb guru ... but I think, yes, you are right.
I add this to a v2 (if this patch has a chance to go in mainline).

Thanks!

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
