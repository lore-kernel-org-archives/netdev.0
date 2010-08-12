From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Thu, 12 Aug 2010 13:31:13 -0700
Message-ID: <AANLkTimWmJ5mTOswT8oJx7MXckzDWcSySZdAu6HZb6r7@mail.gmail.com>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
	<20100812120044.5b1880ad@s6510>
	<20100812121600.2e971e66@s6510>
	<AANLkTinM2m-dK2FYw5VBi3eBAhBRrrzZ+vH5aCtDoDVS@mail.gmail.com>
	<20100812151819.282636fe@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39674 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933606Ab0HLUbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 16:31:14 -0400
Received: by vws3 with SMTP id 3so970956vws.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 13:31:13 -0700 (PDT)
In-Reply-To: <20100812151819.282636fe@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The status values indicate that the GMAC (frame parser) got a reasonable
> size frame but the DMA merged frames together. This indicates a timing
> problem. There are some bits which even with NDA programmers manual doesn't
> help with. The Linux driver expects the BIOS or EEPROM to set them correctly
> because different problems different settings.
>
> There is firmware in eeprom that configures internal state. On one motherboard
> the vendor provided an update. There is no good way to update this from Linux,
> you need to go system vendor and install firmware with their native OS (ie Windows
> or MacOS).

Perfectly reasonable response.  If there was a firmware update fix,
I'd apply it...
That would presumably prevent this from ever happening in the first place.

But why doesn't the network driver reset the nic when it detects this
'rx length' error?

I'm not asking for the error to not happen (besides it happens very rarely)...

I'm asking, why does this error happening permanently hose the network driver.
Once this happens the network card is not usable - traffic does not
flow through it.
You need to "ip link set down && ... up" to fix it.  Isn't this
something the driver could and should do all by itself?
