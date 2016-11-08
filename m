From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Tue, 08 Nov 2016 17:49:21 +0100
Message-ID: <87eg2lkjce.fsf@miraculix.mork.no>
References: <Pine.LNX.4.44L0.1611081020550.1499-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        Oliver Neukum <oneukum@suse.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1611081020550.1499-100000@iolanthe.rowland.org>
        (Alan Stern's message of "Tue, 8 Nov 2016 10:25:26 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Stern <stern@rowland.harvard.edu> writes:

> On Tue, 8 Nov 2016, Kai-Heng Feng wrote:
>
>> Hi,
>>=20
>> On Mon, Nov 7, 2016 at 7:02 PM, Oliver Neukum <oneukum@suse.com> wrote:
>> > On Fri, 2016-11-04 at 17:57 +0800, Kai-Heng Feng wrote:
>> >> Sometimes cdc_mbim failed to probe if runtime pm is enabled:
>> >> [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
>> >>
>> >> This can be solved by increase its pm usage counter.
>> >>
>> >> Signed-off-by: Kai-Heng Feng <kai.heng.feng@canonical.com>
>> >
>> > For the record:
>> >
>> > NAK. This fixes a symptom. If this patch helps something is broken in
>> > device core. We need to find that.
>> >
>>=20
>> Please check attached dmesg with usbcore.dyndbg=3D"+p".
>
> The log shows that the device went into suspend _before_ the cdc_mbim=20
> driver was probed, not during the probe.  Then just before the probe=20
> was started, the USB core tried to resume the device and the resume=20
> failed.
>
> The log shows a bunch of other problems with this device:
>
> [    3.862253] usb 2-2: config 1 has an invalid interface number: 12 but =
max is 1
> [    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but =
max is 1
> [    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but =
max is 1
> [    3.862255] usb 2-2: config 1 has no interface number 0
> [    3.862256] usb 2-2: config 1 has no interface number 1

These messages are completely harmless and normal for Sierra Wireless
devices.  They use the interface number to identify the type of
function, causing this mismatch between the number of interfaces and the
inteface numbers. Boy, that looks weird in writing :)

Ref this discussion we had a few years ago:
http://www.spinics.net/lists/linux-usb/msg77499.html

No, I didn't expect you to remember that :)


> [    8.295180] usb 2-2: Disable of device-initiated U1 failed.
> [    8.295322] usb 2-2: Disable of device-initiated U2 failed.
>
> I get the impression that the device won't work properly with runtime=20
> PM at all.

I suspect the device is an EM7455?  If so, then it does work fine with
runtime PM, as long as we're talking USB2.  Not sure about USB3 runtime
PM though.  Cannot test it. The Lenovo laptop I got with one of these
modems has disabled the USB3 link on the m.2 modem slot for some reason.


Bj=C3=B8rn
