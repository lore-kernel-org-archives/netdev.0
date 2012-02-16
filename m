From: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/5] usb: usbnet: Add validation of dev->maxpacket to
 usbnet
Date: Thu, 16 Feb 2012 10:55:05 +0000
Message-ID: <4F3CE089.5000105@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com> <1329317261-3406-5-git-send-email-toby.gray@realvnc.com> <201202152034.03000.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201202152034.03000.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15/02/12 19:34, Oliver Neukum wrote:
> Am Mittwoch, 15. Februar 2012, 15:47:40 schrieb Toby Gray:
>> Several parts of usbnet rely on dev->maxpacket not being set to 0 to
>> prevent division by zero errors.
>>
>> This adds validation of the dev->maxpacket value being non-zero before
>> treating the device probe as successful.
>>
>> Signed-off-by: Toby Gray<toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
>> ---
>>   drivers/net/usb/usbnet.c |    4 ++++
>>   1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 4ccd316..1491c90 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -1427,6 +1427,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>>   		dev->rx_urb_size = dev->hard_mtu;
>>   	if (!dev->maxpacket)
>>   		dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
>> +	if (!dev->maxpacket) {
>> +		status = -ENODEV;
>> +		goto out3;
> Hm. I am sceptical. If this happens a subdriver is buggy. We should
> not hide that. I am afraid I have to reject this patch.

That's understandable, I almost didn't include it in the series. The 
only reason I added this to the patch series was because I spent a while 
trying to track down a division by zero, when it turns out it was 
actually due to dev->maxpacket being zero when usbnet_start_xmit tried 
to calculate length % dev->maxpacket.

Would you prefer that I drop this patch entirely or just change it to 
something like a BUG_ON?

Regards,

Toby
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
