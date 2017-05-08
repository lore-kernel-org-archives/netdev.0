From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/4] TI Bluetooth serdev support
Date: Mon, 8 May 2017 16:12:16 -0500
Message-ID: <CAL_JsqKBAPUPRtn+pEtz8B8pCrA=45RkEq6X_0i_HYoWsVmtyw@mail.gmail.com>
References: <20170405183005.20570-1-robh@kernel.org> <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
 <20170430160430.rmyuo6sdrkrjxjg6@earth> <CAHCN7x+Mq=b6RN-ezU0400W=H=D7DR+Es1FHtT4GyozpVd8ALA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHCN7x+Mq=b6RN-ezU0400W=H=D7DR+Es1FHtT4GyozpVd8ALA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 5, 2017 at 9:51 AM, Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Sun, Apr 30, 2017 at 11:04 AM, Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> Hi,
>>
>> On Sun, Apr 30, 2017 at 10:14:20AM -0500, Adam Ford wrote:
>>> On Wed, Apr 5, 2017 at 1:30 PM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>> > This series adds serdev support to the HCI LL protocol used on TI BT
>>> > modules and enables support on HiKey board with with the WL1835 module.
>>> > With this the custom TI UIM daemon and btattach are no longer needed.
>>>
>>> Without UIM daemon, what instruction do you use to load the BT firmware?
>>>
>>> I was thinking 'hciattach' but I was having trouble.  I was hoping you
>>> might have some insight.
>>>
>>>  hciattach -t 30 -s 115200 /dev/ttymxc1 texas 3000000 flow  Just
>>> returns a timeout.
>>>
>>> I modified my i.MX6 device tree per the binding documentation and
>>> setup the regulators and enable GPIO pins.
>>
>> If you configured everything correctly no userspace interaction is
>> required. The driver should request the firmware automatically once
>> you power up the bluetooth device.
>>
>> Apart from DT changes make sure, that the following options are
>> enabled and check dmesg for any hints.
>>
>> CONFIG_SERIAL_DEV_BUS
>> CONFIG_SERIAL_DEV_CTRL_TTYPORT
>> CONFIG_BT_HCIUART
>> CONFIG_BT_HCIUART_LL
>>
>
>
> I have enabled those flags, and I have updated my device tree.
> I am testing this on an OMAP3630 (DM3730) board with a WL1283.  I am
> getting a lot of timeout errors.  I tested this against the original
> implemention I had in pdata-quirks.c using the ti-st driver, uim & and
> the btwilink driver.
>
> I pulled in some of the newer patches to enable the wl1283-st, but I
> am obviously missing something.
>
> I   58.717651] Bluetooth: hci0: Reading TI version information failed
> (-110)
> [   58.724853] Bluetooth: hci0: download firmware failed, retrying...
> [   60.957641] Bluetooth: hci0 command 0x1001 tx timeout
> [   68.957641] Bluetooth: hci0: Reading TI version information failed
> (-110)
> [   68.964843] Bluetooth: hci0: download firmware failed, retrying...
> [   69.132171] Bluetooth: Unknown HCI packet type 06
> [   69.138244] Bluetooth: Unknown HCI packet type 0c
> [   69.143249] Bluetooth: Unknown HCI packet type 40
> [   69.148498] Bluetooth: Unknown HCI packet type 20
> [   69.153533] Bluetooth: Data length is too large
> [   69.158569] Bluetooth: Unknown HCI packet type a0
> [   69.163574] Bluetooth: Unknown HCI packet type 00
> [   69.168731] Bluetooth: Unknown HCI packet type 00
> [   69.173736] Bluetooth: Unknown HCI packet type 34
> [   69.178924] Bluetooth: Unknown HCI packet type 91
> [   71.197631] Bluetooth: hci0 command 0x1001 tx timeout
> [   79.197662] Bluetooth: hci0: Reading TI version information failed (-110)

There's a bug in serdev_device_write(), so if you have that function
you need either the fix I sent or the patch to make
serdev_device_writebuf atomic again. Both are on the linux-serial
list, but not in any tree yet.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
