From: Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for
 rndis
Date: Wed, 24 Sep 2014 21:22:21 +0700
Message-ID: <5422D39D.70006@gmail.com>
References: <1411541339-32400-1-git-send-email-hs@denx.de> <5422B83A.8030406@gmail.com> <5422C33F.400@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Macpaul Lin <macpaul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: hs-ynQEQJNshbs@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5422C33F.400-ynQEQJNshbs@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014-09-24 20:12, Heiko Schocher wrote:
> Hello Lars,
>
> Am 24.09.2014 14:25, schrieb Lars Melin:
>> On 2014-09-24 13:48, Heiko Schocher wrote:
>>> use the values for RNDIS over Ethernet as defined in
>>> http://www.usb.org/developers/defined_class
>>> (search for RDNIS):
>>>
>>> - baseclass: 0xef (miscellaneous)
>>> - subclass: 0x04
>>> - protocol: 0x01
>>>
>> That is usb class, it is not the same thing as communication device 
>> class.
>>> --- a/include/uapi/linux/usb/cdc.h
>>> +++ b/include/uapi/linux/usb/cdc.h
>>> @@ -12,6 +12,7 @@
>>> #include <linux/types.h>
>>> #define USB_CDC_SUBCLASS_ACM 0x02
>>> +#define USB_CDC_SUBCLASS_RNDIS 0x04
>> No, no, no.
>> There is no CDC_SUBCLASS_RNDIS and you can not define one over an 
>> already used cdc subclass number, 0x04 is Multi-Channel Control Model
>
> Ah, ok, so I have to define this values in a new header file, as there
> is no current file for the USB_CLASS_MISC defines? Or is there a proper
> place for them?
>
> BTW: where do I find the "cdc subclass number, 0x04 is Multi-Channel
> Control Model" define?
>
> bye,
> Heiko

You can still find the original specification usbcdc11.pdf on the net if 
you google for it, it has been pulled from usb.org where you could 
download it until a few years ago.
It is old but covers a lot of what you need to know.

Linux has afaik only the cdc.h definition file, everything else is coded 
by class/subclass in respectively drivers when needed.
02/02/ff  or  e0/01/03  are the most common interface attribute for 
rndis,  both of them together with a data interface with attributes 
0a/00/00.
Please check the whitelisting in drivers/net/usb/rndis_host.c  and also 
blacklistings in other net drivers under the same path, it should give 
you an idea how to bind an interface to a specific driver by interface 
attributes and/or usb vid:pid.
You should be able to do the same for your particular device.
