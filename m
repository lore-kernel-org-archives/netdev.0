From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sun, 19 Jun 2011 23:53:28 +0200
Message-ID: <4DFE6FD8.1080003@gmail.com>
References: <20110611200625.GB14582@kroah.com> <201106141049.39150.oneukum@suse.de> <4DF72A90.1070702@gmail.com> <201106141146.19097.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201106141146.19097.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14. juni 2011 11:46, Oliver Neukum wrote:
> Am Dienstag, 14. Juni 2011, 11:32:00 schrieb Marius Kotsbak:
>> Den 14. juni 2011 10:49, skrev Oliver Neukum:
>>> Am Samstag, 11. Juni 2011, 23:55:18 schrieb Marius B. Kotsbak:
>>>
>>>> +static int
>>>> +kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
>>>> +{
>>>> +	char init_msg_1[] =
>>>> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
>>>> +		0x00, 0x00 };
>>>> +	char init_msg_2[] =
>>>> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
>>>> +		0x00, 0x00 };
>>>> +	char receive_buf[28];
>>> You are doing DMA on the stack. This will fail on some architectures.
>>>
>> Okay, a bit strange that this API is available then. Which API functions 
>> should be used in this case?
> The API is correct. You just need to copy the init strings into buffers
> allocated with kmalloc.
>

This should be addressed in the extra patch just sent. And it still
works on my x86-64.

The 2 patches might be squashed if desired.

>
> Will the compiler put those strings into the image or build them on
> the stack each time the function is called? Shouldn't they be static?
>

Fixed. It probably improves performance too.
>> Anyway it should not do any damage for anyone (I think even the driver 
>> disk is available with this included). The module could in fact also do 
>> the switch into modem mode to avoid the dependency on usb_modeswitch.
> Please don't do that. It has been decided to put such things into usb_modeswitch
> for now.

Okay, I can see the reasoning behind that. The problem is just that it
would be nice to avoid it because >1.1.4 versions of it does not work
with this modem, but that can be addressed there as well.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
