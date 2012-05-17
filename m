From: Xiao Jiang <jgq516@gmail.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Thu, 17 May 2012 16:40:46 +0800
Message-ID: <4FB4B98E.7000208@gmail.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com> <1337168320.4107.42.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337168320.4107.42.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> On Wed, 2012-05-16 at 16:01 +0800, jgq516@gmail.com wrote:
>   
>> From: Xiao Jiang <jgq516@gmail.com>
>>
>> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devices
>> which possibly use "usb%d" names, add this flag to make sure pandaboard
>> can mount nfs with smsc95xx NIC.
>>     
>
> These are normal Ethernet interfaces, whereas FLAG_POINTTOPOINT is for
> devices that use non-standard short physical links.
>
>   
This flag is used by some usb NICs, I amn't familiar with those cards 
perhaps those are
non-standard short physical links as you said.
But smsc95xx seems need this flag to use "usb%d" name, at least my 
pandaboard can't
mount nfs with eth0 name, is there other ways to avoid nfs issue with 
keep smsc95xx's
name unchange? thanks.

-bash-3.2$ grep FLAG_POINTTOPOINT * -r
drivers/net/usb/zaurus.c:    .flags =    FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
drivers/net/usb/zaurus.c:    .flags =    FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
drivers/net/usb/zaurus.c:    .flags =    FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
drivers/net/usb/zaurus.c:    .flags =    FLAG_POINTTOPOINT | FLAG_FRAMING_Z,
drivers/net/usb/cdc_ncm.c:    .flags = FLAG_POINTTOPOINT | 
FLAG_NO_SETINT | FLAG_MULTI_PACKET,
drivers/net/usb/gl620a.c:    .flags =    FLAG_POINTTOPOINT | 
FLAG_FRAMING_GL | FLAG_NO_SETINT,
drivers/net/usb/plusb.c:    .flags =    FLAG_POINTTOPOINT | FLAG_NO_SETINT,
drivers/net/usb/usbnet.c:            ((dev->driver_info->flags & 
FLAG_POINTTOPOINT) == 0 ||
drivers/net/usb/cdc_subset.c:    .flags       = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags       = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags       = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_subset.c:    .flags = FLAG_POINTTOPOINT,
drivers/net/usb/cdc_eem.c:    .flags =    FLAG_ETHER | FLAG_POINTTOPOINT,
drivers/net/usb/rndis_host.c:    .flags =    FLAG_ETHER | 
FLAG_POINTTOPOINT | FLAG_FRAMING_RN | FLAG_NO_SETINT,
drivers/net/usb/rndis_host.c:    .flags =    FLAG_ETHER | 
FLAG_POINTTOPOINT | FLAG_FRAMING_RN | FLAG_NO_SETINT,
drivers/net/usb/cdc_ether.c:    .flags =    FLAG_ETHER | FLAG_POINTTOPOINT,
drivers/net/usb/net1080.c:    .flags =    FLAG_POINTTOPOINT | 
FLAG_FRAMING_NC,
include/linux/usb/usbnet.h:#define FLAG_POINTTOPOINT 0x1000    /* 
possibly use "usb%d" names */

Regards,
Xiao
> Ben.
>
>   
>> Signed-off-by: Xiao Jiang <jgq516@gmail.com>
>> ---
>>  drivers/net/usb/smsc95xx.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
>> index 94ae669..e158288 100644
>> --- a/drivers/net/usb/smsc95xx.c
>> +++ b/drivers/net/usb/smsc95xx.c
>> @@ -1192,7 +1192,8 @@ static const struct driver_info smsc95xx_info = {
>>  	.rx_fixup	= smsc95xx_rx_fixup,
>>  	.tx_fixup	= smsc95xx_tx_fixup,
>>  	.status		= smsc95xx_status,
>> -	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
>> +	.flags		= FLAG_ETHER | FLAG_POINTTOPOINT | FLAG_SEND_ZLP |
>> +			  FLAG_LINK_INTR,
>>  };
>>  
>>  static const struct usb_device_id products[] = {
>>     
>
>   
