From: Adam Ford <aford173@gmail.com>
Subject: Re: [PATCH 0/4] TI Bluetooth serdev support
Date: Sat, 28 Oct 2017 06:33:58 -0500
Message-ID: <CAHCN7xKTqJ4ZkvUg_4xHYPF+bvjXT=zGbYFP_DKii0S3WQeKew@mail.gmail.com>
References: <20170405183005.20570-1-robh@kernel.org> <CAHCN7xJUxZm1qKAxT0kaK6qoDg+HWOJK7sTH-q9za4HJuUwe8Q@mail.gmail.com>
 <20170430160430.rmyuo6sdrkrjxjg6@earth> <CAHCN7x+Mq=b6RN-ezU0400W=H=D7DR+Es1FHtT4GyozpVd8ALA@mail.gmail.com>
 <CAL_JsqKBAPUPRtn+pEtz8B8pCrA=45RkEq6X_0i_HYoWsVmtyw@mail.gmail.com>
 <20170509044837.oje2tfodytyuuuur@sapphire.tkos.co.il> <CAL_Jsq+wJfepPRbpL-_BWtD2Nyviy0q2UW9s7MrNr392W8D0cA@mail.gmail.com>
 <CAHCN7xKNWa2yrquvYg41CtTWa7aqETNx_08SPgsxv6QC4GK_Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Baruch Siach <baruch@tkos.co.il>,
        Mark Rutland <mark.rutland@arm.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Gustavo Padovan <gustavo@padovan.org>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>,
        Wei Xu <xuwei5@hisilicon.com>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Eyal Reizer <eyalr@ti.com>, netdev <netdev@vger.kernel.org>,
        Satish Patel <satish.patel@linaro.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:48862 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ1LeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:34:00 -0400
In-Reply-To: <CAHCN7xKNWa2yrquvYg41CtTWa7aqETNx_08SPgsxv6QC4GK_Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 5:55 AM, Adam Ford <aford173@gmail.com> wrote:
> On Tue, May 9, 2017 at 9:14 AM, Rob Herring <robh@kernel.org> wrote:
>> On Mon, May 8, 2017 at 11:48 PM, Baruch Siach <baruch@tkos.co.il> wrote:
>>> Hi Rob,
>>>
>>> On Mon, May 08, 2017 at 04:12:16PM -0500, Rob Herring wrote:
>>>> On Fri, May 5, 2017 at 9:51 AM, Adam Ford <aford173@gmail.com> wrote:
>>>> > On Sun, Apr 30, 2017 at 11:04 AM, Sebastian Reichel <sre@kernel.org> wrote:
>>>> >> On Sun, Apr 30, 2017 at 10:14:20AM -0500, Adam Ford wrote:
>>>> >>> On Wed, Apr 5, 2017 at 1:30 PM, Rob Herring <robh@kernel.org> wrote:
>>>> >>> > This series adds serdev support to the HCI LL protocol used on TI BT
>>>> >>> > modules and enables support on HiKey board with with the WL1835 module.
>>>> >>> > With this the custom TI UIM daemon and btattach are no longer needed.
>>>> >>>
>>>> >>> Without UIM daemon, what instruction do you use to load the BT firmware?
>>>> >>>
>>>> >>> I was thinking 'hciattach' but I was having trouble.  I was hoping you
>>>> >>> might have some insight.
>>>> >>>
>>>> >>>  hciattach -t 30 -s 115200 /dev/ttymxc1 texas 3000000 flow  Just
>>>> >>> returns a timeout.
>>>> >>>
>>>> >>> I modified my i.MX6 device tree per the binding documentation and
>>>> >>> setup the regulators and enable GPIO pins.
>>>> >>
>>>> >> If you configured everything correctly no userspace interaction is
>>>> >> required. The driver should request the firmware automatically once
>>>> >> you power up the bluetooth device.
>>>> >>
>>>> >> Apart from DT changes make sure, that the following options are
>>>> >> enabled and check dmesg for any hints.
>>>> >>
>>>> >> CONFIG_SERIAL_DEV_BUS
>>>> >> CONFIG_SERIAL_DEV_CTRL_TTYPORT
>>>> >> CONFIG_BT_HCIUART
>>>> >> CONFIG_BT_HCIUART_LL
>>>> >
>>>> > I have enabled those flags, and I have updated my device tree.
>>>> > I am testing this on an OMAP3630 (DM3730) board with a WL1283.  I am
>>>> > getting a lot of timeout errors.  I tested this against the original
>>>> > implemention I had in pdata-quirks.c using the ti-st driver, uim & and
>>>> > the btwilink driver.
>>>> >
>>>> > I pulled in some of the newer patches to enable the wl1283-st, but I
>>>> > am obviously missing something.
>>>> >
>>>> > I   58.717651] Bluetooth: hci0: Reading TI version information failed
>>>> > (-110)
>>>> > [   58.724853] Bluetooth: hci0: download firmware failed, retrying...
>>>> > [   60.957641] Bluetooth: hci0 command 0x1001 tx timeout
>>>> > [   68.957641] Bluetooth: hci0: Reading TI version information failed
>>>> > (-110)
>>>> > [   68.964843] Bluetooth: hci0: download firmware failed, retrying...
>>>> > [   69.132171] Bluetooth: Unknown HCI packet type 06
>>>> > [   69.138244] Bluetooth: Unknown HCI packet type 0c
>>>> > [   69.143249] Bluetooth: Unknown HCI packet type 40
>>>> > [   69.148498] Bluetooth: Unknown HCI packet type 20
>>>> > [   69.153533] Bluetooth: Data length is too large
>>>> > [   69.158569] Bluetooth: Unknown HCI packet type a0
>>>> > [   69.163574] Bluetooth: Unknown HCI packet type 00
>>>> > [   69.168731] Bluetooth: Unknown HCI packet type 00
>>>> > [   69.173736] Bluetooth: Unknown HCI packet type 34
>>>> > [   69.178924] Bluetooth: Unknown HCI packet type 91
>>>> > [   71.197631] Bluetooth: hci0 command 0x1001 tx timeout
>>>> > [   79.197662] Bluetooth: hci0: Reading TI version information failed (-110)
>>>>
>>>> There's a bug in serdev_device_write(), so if you have that function
>>>> you need either the fix I sent or the patch to make
>>>> serdev_device_writebuf atomic again. Both are on the linux-serial
>>>> list, but not in any tree yet.
>>>
>>> You refer to the patches below, right?
>>>
>>>   [PATCH] tty: serdev: fix serdev_device_write return value,
>>>   http://www.spinics.net/lists/linux-serial/msg26117.html
>>>
>>>   [PATCH] serdev: Restore serdev_device_write_buf for atomic context,
>>>   http://www.spinics.net/lists/linux-serial/msg26113.html
>>
>> Yes, either one will fix the issue.
>
> I am finally getting back to testing these on my DM3730 board, since
> it appears most of the patches appear upstream.  I am having trouble
> remembering how to load this.
>
> # modprobe hci_uart
> [   31.639892] Bluetooth: Core ver 2.22
> [   31.643890] NET: Registered protocol family 31
> [   31.648559] Bluetooth: HCI device and connection manager initialized
> [   31.655975] Bluetooth: HCI socket layer initialized
> [   31.661315] Bluetooth: L2CAP socket layer initialized
> [   31.667175] Bluetooth: SCO socket layer initialized
> [   31.700408] Bluetooth: HCI UART driver ver 2.3
> [   31.705108] Bluetooth: HCI UART protocol H4 registered
> [   31.710632] Bluetooth: HCI UART protocol BCSP registered
> [   31.716217] Bluetooth: HCI UART protocol Three-wire (H5) registered
> #
>
> Unfortunately, any attempt to access the HCI device (ie hciconfig up
> hci0) fail.
>
> I have those configs enabled:
> CONFIG_SERIAL_DEV_BUS
> CONFIG_SERIAL_DEV_CTRL_TTYPORT
> CONFIG_BT_HCIUART
> CONFIG_BT_HCIUART_LL
>
> I can see that sysfs shows new files appear:
>
> /sys/class/bluetooth
> /sys/firmware/devicetree/base/ocp@68000000/serial@4806c000/bluetooth
> /sys/firmware/devicetree/base/ocp@68000000/serial@4806c000/bluetooth/compatible
> /sys/firmware/devicetree/base/ocp@68000000/serial@4806c000/bluetooth/enable-gpios
> /sys/firmware/devicetree/base/ocp@68000000/serial@4806c000/bluetooth/name
>
> (and more)
> So it appears to me like it has loaded, and I don't see any errors during load.
>
> Since this worked under pdata quirks and the older shared transport
> driver and UIM, I'm sure it's software and not hardware.  I just can't
> figure out what I am missing.
>

Nevermind. Sorry for the noise, I got past this part.  I had a typo in
my device tree.


> thanks
>
> adam
>>
>> Rob
