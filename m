From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 19:46:38 -0600
Message-ID: <4F0E3B7E.8040005@lwfinger.net>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com> <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com> <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com> <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
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
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33568 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab2ALBqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 20:46:42 -0500
Received: by iabz25 with SMTP id z25so1924411iab.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 17:46:41 -0800 (PST)
In-Reply-To: <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2012 07:06 PM, Linus Torvalds wrote:
> On Wed, Jan 11, 2012 at 9:00 AM, Larry Finger<Larry.Finger@lwfinger.net>  wrote:
>> --- wireless-testing-new.orig/drivers/bcma/sprom.c
>> +++ wireless-testing-new/drivers/bcma/sprom.c
>> @@ -230,6 +230,7 @@ int bcma_sprom_get(struct bcma_bus *bus)
>>          * TODO: understand this condition and use it */
>>         offset = (bus->chipinfo.id == 0x4331) ? BCMA_CC_SPROM :
>>                 BCMA_CC_SPROM_PCIE6;
>> +       pr_debug("SPROM offset 0x%x\n", offset);
>>         bcma_sprom_read(bus, offset, sprom);
>>
>>         if (bus->chipinfo.id == 0x4331)
>
> So I did that - the offset is printed out as 0x0830
> (BCMA_CC_SPROM_PCIE6). And when I change the offset to 0x0800
> (BCMA_CC_SPROM), the complaint about SPROM version goes away.
>
> IOW, these messages no longer exist:
>
> [    0.815750] bcma: Unsupported SPROM revision: 255
> [    0.815804] bcma: No SPROM available
>
> but that doesn't actually make anything *work*. The brcms errors still
> remain the same.
>
> So the SPROM issue seems to be real, but irrelevant.
>
> I also noticed that the CONFIG_BRCMDBG onyl enables pr_debug(), but
> doesn't actually #define DEBUG, so pr_debug() gets compiled out
> anyway.
>
> I'll try with -DDEBUG in the brcm80211 subdirectory and see if I get
> more interesting output that way.

OK. The SPROM issue is not completely irrelevant as that has to be correct, but 
obviously not sufficient.

What is the PCI ID for your device?

Larry
