From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: smsc95xx: Add device tree input for MAC address
Date: Mon, 7 Oct 2013 19:42:38 +0800
Message-ID: <CACVXFVNAB3VnmdoP_LGJsBjQ17j1aoqKMsBE7LRt65OqROeRUQ@mail.gmail.com>
References: <1380911156-14112-1-git-send-email-dmurphy@ti.com>
	<CACVXFVOVMvP=3y9h2Jrqn2sBQdKOZtrhQDAFYkdHKXFgQj=d0Q@mail.gmail.com>
	<52519E7A.40804@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>, mugunthanvnm@ti.com
To: Dan Murphy <dmurphy@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52519E7A.40804@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 7, 2013 at 1:31 AM, Dan Murphy <dmurphy@ti.com> wrote:
> On 10/06/2013 10:05 AM, Ming Lei wrote:
>> On Sat, Oct 5, 2013 at 2:25 AM, Dan Murphy <dmurphy@ti.com> wrote:
>>> If the smsc95xx does not have a valid MAC address stored within
>>> the eeprom then a random number is generated.  The MAC can also
>>> be set by uBoot but the smsc95xx does not have a way to read this.
>>>
>>> Create the binding for the smsc95xx so that uBoot can set the MAC
>>> and the code can retrieve the MAC from the modified DTB file.
>> Suppose there are two smsc95xx usbnet devices connected to usb bus, and
>> one is built-in, another is hotplug device, can your patch handle the situation
>> correctly?
>
> Look at this line in the patch below
>
> sprintf(of_name, "%s%i", SMSC95XX_OF_NAME, dev->udev->dev.id);
>
> I am appending the dev ID of the device to the of_name here.  As long as init_mac_address is called, the dev.id and the uBoot
> entry match then yes.

Currently, non-root-hub usb device is created and added into usb bus without
any platform(device tree) knowledge, so you can't expect the match here.

Also not mention the two smsc95xx devices may attach to two different
usb host controllers(buses).

Thanks,
-- 
Ming Lei
