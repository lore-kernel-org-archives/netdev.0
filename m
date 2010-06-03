From: Sujith <Sujith.Manoharan@atheros.com>
Subject: Re: [PATCH 1/8] ath9k: Determine Firmware on probe
Date: Thu, 3 Jun 2010 06:28:20 +0530
Message-ID: <19462.65068.93701.741079@gargle.gargle.HOWL>
References: <19462.12578.143627.398866@gargle.gargle.HOWL>
	<AANLkTiky9UF-aqeZCFleOFSIVw3vDiYbLUdTkkYEWN2B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 17:57:07 -0700
In-Reply-To: <AANLkTiky9UF-aqeZCFleOFSIVw3vDiYbLUdTkkYEWN2B@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> I had done some something similar for ar9170 a while back [1] when
> adding AVM FRITZ support to ar9170 and then got complaints from Marcel
> on this approach since it requires synching the PCI device IDs in two
> places. I frankly don't care how we do this but we should try to at
> least stick to one way of doing this.
> 
> [1] http://osdir.com/ml/linux-wireless/2009-05/msg01219.html

I did look at using the device_id table (using USB_DEVICE_VER),
but our case is like this:

* for prodId, version 2.2 load foo_1_1.fw
* for prodId, version everything else, load foo.fw

This requires a bit of handling in the driver, hence this patch.

But thinking about it, will this work ?

USB_DEVICE_VER(vend, 0x7010, 2, 2); [set .driver_info to "foo_1_1.fw]
USB_DEVICE(vend, 0x7010);           [set .driver_info to "foo.fw"]

That is, will the second registration be the fallback case in case
bcdLo and bcdHi are _anything_ other than 2.2 ?

Sujith
