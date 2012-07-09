From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Mon, 9 Jul 2012 12:18:17 +0200
Message-ID: <CABkLObqMkmN=N=KX6wk5roVtQRSL18YaD-tcRrJ-rs+0YzxhkA@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<002b01cd5d7b$ff4f7390$fdee5ab0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>,
	=?UTF-8?B?QVNJWCBGcmVkZHkgW+i+m+aBhuixkF0=?= <freddy@asix.com.tw>
To: "ASIX Allan Email [office]" <allan@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:55962 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab2GIKSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:18:17 -0400
Received: by ghrr11 with SMTP id r11so9893645ghr.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:18:17 -0700 (PDT)
In-Reply-To: <002b01cd5d7b$ff4f7390$fdee5ab0$@com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allan,
Thank you for your email and your support! I would be happy if you
would have a look
at the patches, comment on them and test them :-)

On Mon, Jul 9, 2012 at 4:38 AM, ASIX Allan Email [office]
<allan@asix.com.tw> wrote:
> Dear All,
>
> Thanks a lot for your great efforts to support AX88172A on Linux kernel mainline source.
>
> The following information might be useful for you to implement AX88172A Linux driver in
> Linux kernel mainline source. Most of AX88172A customers' applications will
> implement their target applications through the MII interface in MAC mode or through
> the Rev-MII/Rev-RMII in PHY mode, such as AX88172A (MAC mode) + external fiber
> PHY, AX88172A (PHY mode or Dual-PHY mode) + external MAC controller, etc. ASIX
> uses AX88172A EEPROM offset 17h (as Software Field setting, the AX88172A drivers
> will check this field value to identify the exact applications for different driver initialization
> procedures) to identify different customers' applications.
>
> For the AX88172A (PHY mode or Dual-PHY mode) + external MAC controller
> customers' applications that are embedded applications with AX88172A on-board design,
> customers should have implemented ASIX's AX88172A Linux driver source on their own
> embedded Linux kernel platform directly.
>
> For the AX88172A (MAC mode) + external fiber PHY applications that might be USB
> to Fiber dongle applications, users might plug the USB to Fiber dongle on any Linux
> kernel platforms. You can consider referring to ASIX's AX88172A Linux driver source
> that can be downloaded from AX88172A Driver Download web page
> (http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=96) to support
> these kinds of known dongle solutions on Linux kernel mainline source if necessary.
> Please feel free to let us know if you need more information. Thanks a lot.

Currently I check the state of bits 3:2 (SS[1:0]) of the Software
Interface Selection Status Register (21h) of the AX88172A (see
ax88172a_bind in [1]). If these bits are set to 00 my driver will use
the internal PHY, if they are 01 my driver uses an external PHY. So my
board uses the pull-up/down resistor configuration at pin #59 and pin
#60 to select the operation mode.

If I understand correctly you suggest to use the settings in the
EEPROM at offset 17h instead. Could you please provide more
information about this EEPROM settings? The EEPROM memory map in the
AX88172A documentation ends at offset 14h. Is there a reason why I
should not use the hardware configuration with pins #59 and #60?

Best regards, Christian

[1] http://marc.info/?l=linux-netdev&m=134157545200930&w=2

>
>
> ---
> Best regards,
> Allan Chou
> Technical Support Division
> ASIX Electronics Corporation
> TEL: 886-3-5799500 ext.228
> FAX: 886-3-5799558
> E-mail: allan@asix.com.tw
> http://www.asix.com.tw/
