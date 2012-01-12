From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 22:15:19 -0600
Message-ID: <4F0E5E57.9060204@lwfinger.net>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com> <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com> <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com> <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com> <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53504 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab2ALEPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 23:15:23 -0500
Received: by iabz25 with SMTP id z25so2097257iab.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 20:15:23 -0800 (PST)
In-Reply-To: <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2012 08:11 PM, Linus Torvalds wrote:
> On Wed, Jan 11, 2012 at 5:46 PM, Larry Finger<Larry.Finger@lwfinger.net>  wrote:
>>
>> OK. The SPROM issue is not completely irrelevant as that has to be correct,
>> but obviously not sufficient.
>
> Hmm. Having dug a bit deeper, I do think it's kind of related.
>
> I get -ENODATA form sprom_read_pci(), but that function actually seems
> to get the offset *right*.
>
> Some printout shows that for that chip, I have
>
>   - ai_get_ccrev(sih) = 34
>   - sprom_offset = 0x800
>
> but then it apparently reads all ones anyway. At least in the first
> word. So then I get that -ENODATA error.
>
> So once more, it's somehow related to the sprom, just in a new place:
> sprom_read_pci() in brcmsmac/srom.c instead of drivers/bcma/sprom.c.
>
> Does that give people any new ideas to try out?

Things are getting curious. I have a 14e4:4353 device, which works with both b43 
and brcmsmac using mainline v3.2-6271-g925b5d2. The output of

dmesg | egrep "bcma|brcm"

with some extra debugging added yields:

bcma-pci-bridge 0000:06:00.0: PCI INT A -> Link[LK1E] -> GSI 22 (level, low) -> 
IRQ 22
bcma-pci-bridge 0000:06:00.0: setting latency timer to 64
bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class 0x0)
bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, class 0x0)
bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0)
bcma: Found rev 6 PMU (capabilities 0x108C2606)
bcma: SPROM offset 0x830
bcma: Found SPROM Revision 8
bcma: Bus registered
brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 22
brcmsmac: Found chip type AI (0x1381a8d8)
brcmsmac: Applying 43224B0+ WARs
bcma: Switched to core: 0x812
brcms_module_init: register returned 0

I see no difference in the core revisions, etc. to explain why mine should work, 
and yours fail.

Arend: Any particular place we should look?

Larry
