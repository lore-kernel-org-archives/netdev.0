From: Lars Melin <larsm17@gmail.com>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for
 rndis
Date: Mon, 29 Sep 2014 23:05:21 +0700
Message-ID: <54298341.1080504@gmail.com>
References: <1411541339-32400-1-git-send-email-hs@denx.de> <5422B83A.8030406@gmail.com> <5422C33F.400@denx.de> <5422D39D.70006@gmail.com> <54294C78.6050006@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Macpaul Lin <macpaul@gmail.com>,
	"Meier, Roger" <r.meier@siemens.com>
To: hs@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54294C78.6050006@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-09-29 19:11, Heiko Schocher wrote:
> Hello Lars,
>
> sorry for my late answer ...
>
> Am 24.09.2014 16:22, schrieb Lars Melin:
>> On 2014-09-24 20:12, Heiko Schocher wrote:
>>> Hello Lars,
>>>
>>> Am 24.09.2014 14:25, schrieb Lars Melin:
>>>> On 2014-09-24 13:48, Heiko Schocher wrote:
>>>>> use the values for RNDIS over Ethernet as defined in
>>>>> http://www.usb.org/developers/defined_class
>>>>> (search for RDNIS):
>>>>>
>>>>> - baseclass: 0xef (miscellaneous)
>>>>> - subclass: 0x04
>>>>> - protocol: 0x01
>>>>>
>>>> That is usb class, it is not the same thing as communication device 
>>>> class.
>>>>> --- a/include/uapi/linux/usb/cdc.h
>>>>> +++ b/include/uapi/linux/usb/cdc.h
>>>>> @@ -12,6 +12,7 @@
>>>>> #include <linux/types.h>
>>>>> #define USB_CDC_SUBCLASS_ACM 0x02
>>>>> +#define USB_CDC_SUBCLASS_RNDIS 0x04
>>>> No, no, no.
>>>> There is no CDC_SUBCLASS_RNDIS and you can not define one over an 
>>>> already used cdc subclass number, 0x04 is Multi-Channel Control Model
>>>
>>> Ah, ok, so I have to define this values in a new header file, as there
>>> is no current file for the USB_CLASS_MISC defines? Or is there a proper
>>> place for them?
>>>
>>> BTW: where do I find the "cdc subclass number, 0x04 is Multi-Channel
>>> Control Model" define?
>>>
>>> bye,
>>> Heiko
>>
>> You can still find the original specification usbcdc11.pdf on the net 
>> if you google for it, it has been pulled from usb.org where you could 
>> download it until a few years ago.
>> It is old but covers a lot of what you need to know.
>
> Hmm.. maybe I am to dummy for finding this docment...
>
> http://www.usb.org/results?q=usbcdc11.pdf&submit=Search
>
> does not find this document ... could you send me a direct link?
>
> I found with the above search:
>
> http://www.usb.org/developers/defined_class

I don't know if it is a good idea to provide a link here to a document 
which usb.org has made unavailable, I told you to google for the file 
name , not to search for it on usb.org
> and this site, exactly describes the values for RNDIS over ethernet,
> as my patch changes [1]
>
>> Linux has afaik only the cdc.h definition file, everything else is 
>> coded by class/subclass in respectively drivers when needed.
>
> why not in header files? I thought, magical values are not welcome
> in source code ...
>

I was wrong, usb class definitions are included in 
../include/uapi/linux/usb/ch9.h
> As for the is_rndis() function case, this function is defined in
> 2 places:
>
> - drivers/net/usb/cdc_ether.c
> - drivers/usb/core/generic.c
>
> Has this a special reason? This seems suboptimal to me ...
Yes it has, but the core driver is not an interface driver so it is not 
of relevance in this case.
cdc_ether handles interfaces of device connected to the usb bus, not 
interfaces of gadget devices
created by linux.
> I got from a customer this patch (in a similiar version) and
> he did tests with [3] and saw, that a board which runs linux,
> is seen in [3] with the values [2] ... so he changed the
> values in drivers/usb/gadget/function/f_rndis.c to the
> values [1], which are documented in [4] and with them
> the test [3] is happy ... and the file
> "Documentation/usb/linux.inf" is not longer needed on the
> windows pc!
>
The patch from your customer removed  the most common rndis interface 
attributes and substituted them
with one of many other interface attributes which Microsoft uses, this 
is not the right way of doing it.
Why did he patch  ../core/generic.c  and ../net/usb/cdc_ether.c  if he 
wants to change the interface attributes of g_rndis?


Lars
