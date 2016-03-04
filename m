From: Andrey Konovalov <andreyknvl@gmail.com>
Subject: Re: Possible double-free in the usbnet driver
Date: Sat, 5 Mar 2016 02:22:53 +0300
Message-ID: <CA+fCnZfFgg3TsMAX4rSkyq4JOYcyVM_gRewXH7fVhiLWwSmNKQ@mail.gmail.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
	<CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
	<1457131342.8935.2.camel@suse.de>
	<CA+fCnZdjGLT1wkzZXMJ8WHMzmTqcvUVBEN2tZCvwJQfAab8pyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33077 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760531AbcCDXWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:22:54 -0500
In-Reply-To: <CA+fCnZdjGLT1wkzZXMJ8WHMzmTqcvUVBEN2tZCvwJQfAab8pyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 5, 2016 at 2:00 AM, Andrey Konovalov <andreyknvl@gmail.com> wrote:
> On Sat, Mar 5, 2016 at 1:42 AM, Oliver Neukum <oneukum@suse.de> wrote:
>> On Sat, 2016-03-05 at 01:26 +0300, Andrey Konovalov wrote:
>>> and when I run the vm and connect the device I get:
>>>
>>> [   23.672662] cdc_ncm 1-1:1.6: bind() failure
>>> [   23.673447] usbnet_probe(): freeing netdev: ffff88006ab48000
>>> [   23.675822] usbnet_probe(): freeing netdev: ffff88006ab48000
>>>
>>> So this seems to be a double-free (or at least a double free_netdev()
>>> call), but the object gets freed twice from usbnet_probe() and not
>>> from usbnet_disconnect(), so you're right that the latter doesn't get
>>> called. I'm not sure how usbnet_probe() ends up being called twice.
>>
>> Do you have lsusb?
>
> You mean inside the vm?
> I do.

Or did you want the faulty device descriptor itself?

I used this:

Speed High
Bus 004 Device 003: ID 0bdb:1911
Device Descriptor:
  bLength                 18
  bDescriptorType          1
  bcdUSB                2.00
  bDeviceClass             2 Communications
  bDeviceSubClass          0
  bDeviceProtocol          0
  bMaxPacketSize0         64
  idVendor            0x0000
  idProduct           0x0000
  bcdDevice             0.00
  iManufacturer            1
  iProduct                 2
  iSerial                  3
  bNumConfigurations       1
Configuration Descriptor:
  bLength                  9
  bDescriptorType          2
  wTotalLength           371
  bNumInterfaces          11
  bConfigurationValue      1
  iConfiguration           4
  bmAttributes          0xe0
    Self Powered
    Remote Wakeup
  bMaxPower                0mA
Interface Descriptor:
  bLength                  9
  bDescriptorType          4
  bInterfaceNumber         6
  bAlternateSetting        0
  bNumEndpoints            1
  bInterfaceClass          2 Communications
  bInterfaceSubClass      13
  bInterfaceProtocol       0
  iInterface              11

>
>>
>>         Regards
>>                 Oliver
>>
>>
