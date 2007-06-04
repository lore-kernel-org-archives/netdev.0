From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Subject: Re: [PATCH 2/2] ps3: add wireless LAN support
Date: Mon, 04 Jun 2007 21:41:47 +0900
Message-ID: <20070604151850.2C58.MOKUNO@sm.sony.co.jp>
References: <20070601150802.2C3D.MOKUNO@sm.sony.co.jp> <1180715749.28128.59.camel@xo-28-0B-88.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:52791 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbXFDMl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 08:41:56 -0400
In-Reply-To: <1180715749.28128.59.camel@xo-28-0B-88.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Thank you for your comments!

It seems to be pretty preferable we make the driver wpa_supplicant
compatible, I'll plan to rework and resubmit the patch (to
linux-wireless)


On Fri, 01 Jun 2007 12:35:49 -0400
Dan Williams <dcbw@redhat.com> wrote:
> There are a few basic
> issues, rehashed here:
> 
> 1) Need endian annotations and conversions.

OK, I'll fix. 

> 2) How much WPA does the device really support?  If it only supports
> WPA[2]-PSK, I guess that's OK, but the driver _MUST_ return the WPA and
> RSN information elements from each BSS that provides them using the
> IWEVGENIE tag from the get scan handler.  A hack might be to construct a
> suitable synthetic IE depending on the contents of the 'security' field
> the firmware passes back.  But userspace needs to know that a particular
> BSS supports WPA in a standard manner.

It supports WEP and WPA[2]-PSKs(TKIP and AES) only. 

I'll consider incorporating wpa_supplicant stuff, ie to support IWEVGENIE
parameters.

> 3) Should remove the WPA passphrase bits from the encode functions,
> these functions should operate only on raw key material.  Userspace
> tools do the hashing.

The hypervisor (firmware) has functionality of hashing WPA passphrase. 
So the driver code just passes it to hypervisor.  With that feature, end
users can easily set their passphase.  I thought it was convenient.
Anyway I can remove it to delegate to user space.

> 4) I'd like an explanation of the scanning behavior too, looks fishy.

Well, it basically start to scan as requested.  But since scanning is
time consuming job and it seems to block normal messages, rate control
code you mentioned was inserted.
Background scan is performed for roaming as you thought.

> 
> 5) Should be using a list of scanned BSSs, should be aging and culling
> them, instead of a static array.

OK.

> 
> 6) The private ioctl needs to die.

These private ioctls were made so that we can setup the driver simply
with wireless-tools, like the answer to 3) above.
Anyway I'll try to incorporate wpa_supplicant support.

> 
> 7) Does the device work with wpa_supplicant's 'wext' driver?

I don't think it works with wext of wpa_supplicant, although I didn't test
it with wpa_supplicant well.


--
Masakazu MOKUNO

