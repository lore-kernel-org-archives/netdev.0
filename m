From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Wed, 19 Feb 2014 16:08:17 -0800
Message-ID: <CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
	<CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
	<FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
	<CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
	<65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
	<CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:44800 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaBTAIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 19:08:18 -0500
Received: by mail-ob0-f178.google.com with SMTP id wn1so1300234obc.37
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 16:08:17 -0800 (PST)
In-Reply-To: <CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 1:53 PM, Grant Grundler <grundler@google.com> wrote:
...
>>> /sys/devices/12110000.usb/usb3/3-2/bConfigurationValue
>>
>> Yes. Modify the value from 2 to 1.

Hayes,
Good News! :)

Setting bConfigurationValue to 1 automatically resulted in the r8152 device
driver getting loaded, claiming the device, and establishing a link when the
 last patch is included.

The first time I tried, I might have mucked something up and was
getting something about "interrupt status -71". I disconnected the
device, rebooted, and started with a clean slate. It worked fine the
second time.  I will temporarily add the udev rule you previously
posted in order to automate testing this until I can get HW that comes
up in "vendor mode".

> This value was 1 by default on the ARM systems

I think I was confused by previous attempts to set the value,
rebooting and still
seeing it set to 1. The ARM system now came up with value 2 after
removing/inserting the Realtek 8153 USB dongle.

> where I don't have
> r815x driver and r8152 is claiming the device. I previously tried to
> set this value to 1 and I'm wondering if that value will now "stick"
> until I reboot. I will add c7de7dec patch again and see what it says.

After "echo 1 > ..../bConfigurationValue" dmesg now says:
[  107.676386] r8152 2-1:1.0 eth0: v1.04.0 (2014/01/15)
[  107.676508] usbcore: registered new interface driver r8152
[  107.695634] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[  110.765036] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Thanks for the help Hayes!


cheers,
grant
