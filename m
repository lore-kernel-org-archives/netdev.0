From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Tue, 10 Dec 2013 00:18:44 +0300
Message-ID: <52A633B4.9000307@cogentembedded.com>
References: <1386614601-9453-1-git-send-email-natg@google.com>	<1386615608.1752.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <CAGmqidkxoi9EEe0uC18QQUXwjFP1e_1MXL7VPk+NtU-Ta6FGUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Natarajan Gurumoorthy <natg@google.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:64119 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab3LIUSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 15:18:46 -0500
Received: by mail-la0-f49.google.com with SMTP id er20so1949219lab.8
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 12:18:45 -0800 (PST)
In-Reply-To: <CAGmqidkxoi9EEe0uC18QQUXwjFP1e_1MXL7VPk+NtU-Ta6FGUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/09/2013 10:22 PM, Natarajan Gurumoorthy wrote:

> Michael,
>        We had crashes when the PCI config space got scanned via
> /sys/devices/pcixxxx/....../config.

> I agree that this fix will not help if the scan happens before the tg3
> driver gets loaded.

    Then perhaps a better place for such fixup would be a PCI quirk?

> Regards
> Nat

> On Mon, Dec 9, 2013 at 11:00 AM, Michael Chan <mchan@broadcom.com> wrote:
>> On Mon, 2013-12-09 at 10:43 -0800, Nat Gurumoorthy wrote:
>>> The new tg3 driver leaves REG_BASE_ADDR (PCI config offset 120)
>>> uninitialized. From power on reset this register may have garbage in it. The
>>> Register Base Address register defines the device local address of a
>>> register. The data pointed to by this location is read or written using
>>> the Register Data register (PCI config offset 128). When REG_BASE_ADDR has
>>> garbage any read or write of Register Data Register (PCI 128) will cause the
>>> PCI bus to lock up. The TCO watchdog will fire and bring down the system.


>> Is this to prevent problem from other software that may be scanning the
>> PCI config space?  It won't help if this happens before the tg3 driver
>> is loaded, right?

>> Thanks.

WBR, Sergei
