From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Mon, 17 Feb 2014 09:53:03 -0800
Message-ID: <CAGVrzcahSCf8uMsf5jQ3DiS1y1AdBZrFgxN2p6GdWtEPzXFSig@mail.gmail.com>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk>
 <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk>
 <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com> <53024A62.4050208@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36977 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbaBQRxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 12:53:44 -0500
In-Reply-To: <53024A62.4050208@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-17 9:44 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:
> On 17/02/14 17:33, Florian Fainelli wrote:
>>
>> Hi Ben,
>>
>> 2014-02-17 5:08 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:
>>>
>>> Add new init-regs field for of_phy nodes and make sure these
>>> get applied when the phy is configured.
>>>
>>> This allows any phy node in an fdt to initialise registers
>>> that may not be set as standard by the driver at initialisation
>>> time, such as LED controls.
>>>
>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>> ---
>>>   Documentation/devicetree/bindings/net/phy.txt | 12 ++++++
>>>   drivers/net/phy/phy_device.c                  | 59
>>> ++++++++++++++++++++++++++-
>>>   2 files changed, 70 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/phy.txt
>>> b/Documentation/devicetree/bindings/net/phy.txt
>>> index 58307d0..48d8ded 100644
>>> --- a/Documentation/devicetree/bindings/net/phy.txt
>>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>>> @@ -20,6 +20,8 @@ Optional Properties:
>>>     assume clause 22. The compatible list may also contain other
>>>     elements.
>>>   - max-speed: Maximum PHY supported speed (10, 100, 1000...)
>>> +- init-regs: Set of registers to modify at initialisation as a
>>> +    a set of <register set clear>
>>
>>
>> Should be:
>>
>> "micrel,led-control-init-val" or something like that.
>>
>> first cell is the register address, according to the IEEE 802.3 clause 22
>> second cell is the set bitmask to apply to the register address
>> specified in the first cell
>> third cell is the clear bitmask to apply to the register address
>> specified in the second cell
>>
>> I would rather see this as a specific PHY node DT property for setting
>> the LED control register, because this is totally non-standard and you
>> are touching a proprietary register here.
>
>
> I'd rather stay with this than splattering lots and lots of
> phy specific additions to each phy driver.

And I would rather not do it because:

- Device Tree related problems are already hard enough to debug that
we do not want DT to act as a firmware and provide values for Linux to
digest without even a bit of parsing and validation
- this is not capture by a PHY fixup, and will not be reported as such
in /sys/class/mdio_bus/*/*/phy_has_fixups
- this covers the one time initialization that might be needed, but
does not cover the suspend/resume/reset times where this is also
needed
- this is vendor-specific and sort of calls for being moved into the PHY driver

>
> This has the plus it lets board developers set registers in
> case of board specific initialisation values that are not
> already in the drivers.

And this bloats the code for the other 99% people that do not use
things like this. Do not get me wrong, Ethernet PHYs never work as we
want them to, but we libphy comes with PHY fixups callbacks which
allows you to capture quirks and will ensure that they are run again
at the right time in the PHY state machine cycle.
-- 
Florian
