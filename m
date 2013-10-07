From: Dan Murphy <dmurphy-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] usbnet: smsc95xx: Add device tree input for MAC address
Date: Mon, 7 Oct 2013 08:30:31 -0500
Message-ID: <5252B777.2080102@ti.com>
References: <1380911156-14112-1-git-send-email-dmurphy@ti.com>	<CACVXFVOVMvP=3y9h2Jrqn2sBQdKOZtrhQDAFYkdHKXFgQj=d0Q@mail.gmail.com>	<52519E7A.40804@ti.com> <CACVXFVNAB3VnmdoP_LGJsBjQ17j1aoqKMsBE7LRt65OqROeRUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNAB3VnmdoP_LGJsBjQ17j1aoqKMsBE7LRt65OqROeRUQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 06:42 AM, Ming Lei wrote:
> On Mon, Oct 7, 2013 at 1:31 AM, Dan Murphy <dmurphy-l0cyMroinI0@public.gmane.org> wrote:
>> On 10/06/2013 10:05 AM, Ming Lei wrote:
>>> On Sat, Oct 5, 2013 at 2:25 AM, Dan Murphy <dmurphy-l0cyMroinI0@public.gmane.org> wrote:
>>>> If the smsc95xx does not have a valid MAC address stored within
>>>> the eeprom then a random number is generated.  The MAC can also
>>>> be set by uBoot but the smsc95xx does not have a way to read this.
>>>>
>>>> Create the binding for the smsc95xx so that uBoot can set the MAC
>>>> and the code can retrieve the MAC from the modified DTB file.
>>> Suppose there are two smsc95xx usbnet devices connected to usb bus, and
>>> one is built-in, another is hotplug device, can your patch handle the situation
>>> correctly?
>> Look at this line in the patch below
>>
>> sprintf(of_name, "%s%i", SMSC95XX_OF_NAME, dev->udev->dev.id);
>>
>> I am appending the dev ID of the device to the of_name here.  As long as init_mac_address is called, the dev.id and the uBoot
>> entry match then yes.
> Currently, non-root-hub usb device is created and added into usb bus without
> any platform(device tree) knowledge, so you can't expect the match here.

That is correct.  Platform/dev tree will have no concept of the PnP USB dongle therefore there should be no entry in either.

I will need to test this issue with a PnP usb->ethernet dongle.

Dan




> Also not mention the two smsc95xx devices may attach to two different
> usb host controllers(buses).
>
> Thanks,


-- 
------------------
Dan Murphy

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
