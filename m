From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] net: tulip: turn compile-time warning into dev_warn()
Date: Thu, 19 Nov 2015 13:57:30 -0800
Message-ID: <CAP6odjiimR35N50uKP5Bj=STSbLwntcupsvcGFGcsi9wFFDCZA@mail.gmail.com>
References: <9720627.53btSdPcQU@wuerfel>
	<20151119122610.GF22786@arm.com>
	<564E313B.6000801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, ard.biesheuvel@linaro.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37540 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758977AbbKSV5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:57:31 -0500
Received: by wmww144 with SMTP id w144so135363431wmw.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:57:30 -0800 (PST)
In-Reply-To: <564E313B.6000801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 12:29 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 19/11/15 04:26, Will Deacon wrote:
...
>> /me waits for on-soc tulip integration.
>
> FWIW, this already happened, the ADMtek/Infineon ADM8668 actually
> integrated a Tulip chip. I have not submitted these patches below from
> the OpenWrt tree because the chip is barely used nowadays, and it was
> only mostly popular with the Linksys WRTU54G.
>
> The patches could be made less intrusive if we did convert the pci_dma*
> calls into regular DMA-API calls, which they are nowadays, oh well!

I agree.  IIRC, there was no DMA-API when this driver was written.
James Bottomley added DMA API later and there was no need to convert
since Tulip devices were _only_ PCI at the time.

> https://dev.openwrt.org/browser/trunk/target/linux/adm8668/patches-3.18/004-tulip_pci_split.patch

In general this would be a reasonable patch to submit here with some caveats:
  1) convert to DMA API (first patch)
  2)  add CONFIG_PCI code (second patch) to handle the remaining
discovery and PCI Config space bits.

Some additional minor refactoring of the code could convert this into
a "multi-bus driver" if there is any system that could incorporate
both a platform device and a PCI device.

I expect the conversion to DMA API to be straight forward as the next
patch shows:

> https://dev.openwrt.org/browser/trunk/target/linux/adm8668/patches-3.18/005-tulip_platform.patch

Split this patch into two parts: convert to DMA-API (first patch) and
platform device support (third patch). Should be a "no brainer" to
accept.

Lastly, net/ethernet/dec/tulip driver is up for adoption. I've just
been extremely lazy about updating the MAINTAINERS entry but will
submit that shortly (apologies to Arndt for the bounced email - I know
it's a bit disconcerting to see that.)

I'm happy to continue review tulip code changes anyway.

cheers,
grant

> --
> Florian
