From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: [sky2, solved] transmit timeouts and firmware update...
Date: Wed, 27 Aug 2008 22:48:35 +0100
Message-ID: <6278d2220808271448h155494a0kfdcd155f0de18ee0@mail.gmail.com>
References: <6278d2220808250742r4a2b377al13a516fa0c6b53a9@mail.gmail.com>
	 <alpine.LNX.1.10.0808252048440.25225@bizon.gios.gov.pl>
	 <20080825152206.2d554cf7@speedy> <20080827132727.1851cfba@extreme>
	 <6278d2220808271437r1d6851dbg84e26054d4f3deed@mail.gmail.com>
	 <20080827144218.5c1d2439@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <ole@ans.pl>,
	"Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:18480 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbYH0Vsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:48:36 -0400
Received: by py-out-1112.google.com with SMTP id p76so43106pyb.10
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 14:48:35 -0700 (PDT)
In-Reply-To: <20080827144218.5c1d2439@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 10:42 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Wed, 27 Aug 2008 22:37:51 +0100
> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>
>> On Wed, Aug 27, 2008 at 9:27 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>> > On Mon, 25 Aug 2008 15:22:06 -0400
>> > Stephen Hemminger <shemminger@vyatta.com> wrote:
>> >
>> >> On Mon, 25 Aug 2008 21:03:25 +0200 (CEST)
>> >> Krzysztof Oledzki <ole@ans.pl> wrote:
>> >>
>> >> >
>> >> >
>> >> > On Mon, 25 Aug 2008, Daniel J Blueman wrote:
>> >> >
>> >> > > I (and a lot of other users) have been experiencing the frequent sky2
>> >> > > transmit timeout problem [1] (on 88E8053/Yukon2 EC gig hardware); this
>> >> > > is a result of the embedded NIC controller locking up, and I've found
>> >> > > that updating the firmware addresses this issue. I'm still seeing a
>> >> > > previous and different issue [2] from time to time though (silicon
>> >> > > bug?).
>> >> >
>> >> > Thanks for the info. I've been dealing with this problem for some long
>> >> > time, hopefully sky driver from the latest kernels is able to recover
>> >> > from such hangs, so it is not that critical problem now.
>> >> >
>> >> > > Marvell shipping broken firmware is completely unpublicised or
>> >> > > acknowledged, however updated firmware is available through your
>> >> > > motherboard vendor, so all hope it not lost after all...
>> >> >
>> >> > Unfortunately not through all vendors. :( Or maybe not *yet*?
>> >> >
>> >> > > My 8053/EC is using firmware 2.2 (previously 1.9) - you can check in
>> >> > > DOS with 'yukondg.exe' from
>> >> > > http://www.marvell.com/drivers/files/yukondg_v6.53.4.3.zip .
>> >> >
>> >> > Stephen, is it possible for sky2 driver to check and print the
>> >> > firmware version?
>> >>
>> >> It is possible to dump and program eeprom from linux, and the version
>> >> maybe buried in the VPD, but some hardware has non-functional VPD.
>> >
>> > The revision number in the VPD matches the revision number (from PCI)
>> > that is already printed by the driver. Since I don't have enough documentation
>> > on the firmware to know the format, there is no way to print anything
>> > really useful.
>>
>> $ lspci -d11ab:
>> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
>> PCI-E Gigabit Ethernet Controller (rev 22)
>> 07:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8036
>> PCI-E Fast Ethernet Controller (rev 15)
>>
>> $ dmesg | grep sky2.*rev
>> [   33.998133] sky2 0000:02:00.0: v1.20 addr 0xd6000000 irq 16
>> Yukon-EC (0xb6) rev 2
>> [   33.999085] sky2 0000:07:00.0: v1.20 addr 0xd8000000 irq 18
>> Yukon-FE (0xb7) rev 1
>>
>> The 'rev' reported by the driver is from:
>>
>>         hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
>>
>> which is the chip/silicon revision, whereas the rev reported by the
>> PCI device is the firmware revision, as you've found.
>>
>> How about:
>>
>> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
>> PCI-E Gigabit Ethernet Controller (silicon rev 2, firmware/PCI rev 22)
>>
>> This introduces perhaps something even more useful - we know there are
>> really major issues with (eg) 88E8053 before firmware 2.2; is it worth
>> adding a warning, such as:
>>
>> sky2: firmware earlier than rev 2.2 detected - if you experience
>> transmit timeouts, ask vendor for 88E8053 firmware update
>>
>> There are a lot of bug reports on the web pointing the finger at the
>> sky2 driver, and waiting for a 'fixed' version, but the issue is
>> elsewhere...part of the problem, if there is (almost) no
>> documentation/evidence of this problem posted anywhere.
>>
>> Many thanks,
>>   Daniel
>
> lspci reports PCI rev.  driver reports chip rev.

But the PCI revision is also the firmware revision - I didn't know
this until you mentioned it, so it would be handy to make it explicit
in the driver's output; also we don't always have the 'lspci' output
in bug reports. Let me know if you'd like a patch...

Thanks,
  Daniel
-- 
Daniel J Blueman
