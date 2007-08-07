From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 (was: eepro100) - Nobody Cares (hardware?)
Date: Mon, 06 Aug 2007 17:45:09 -0700
Message-ID: <46B7C095.5010202@intel.com>
References: <20070806152244.M31050@ericj.net> <46B748A8.4030608@garzik.org> <20070806161747.M31655@ericj.net> <20070806205908.M61217@ericj.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>
To: ericj <ericj@ericj.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61353 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761239AbXHGApL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 20:45:11 -0400
In-Reply-To: <20070806205908.M61217@ericj.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[moving to netdev mailinglist]

ericj wrote:
> On Mon, 6 Aug 2007 11:20:58 -0500, ericj wrote
>> On Mon, 06 Aug 2007 12:13:28 -0400, Jeff Garzik wrote
>>> eepro100 is going to be removed.  Please try e100 on 2.6.22 or 
>>> 2.6.23-rc2.
> 
>> I will give the 2.6.23 a try.
> 
> I tried 2.6.23-rc2 and there was no change.
> 
> There is now some question from the hardware guys about whether the
> eeproms were properly configured before shipping the boards. Is there
> any documentation of the eeprom on an EE Pro 100 VE (ICH4) so that I can
> figure out if any of the settings in there might be causing the problem?
> 
> The only fields I know of for sure are the MAC address at the beginning
> and the checksum at the end. I also see from the driver code that there
> is at least one byte controlling wake-on-lan, which I don't care about -
> unless it's the problem.
> 
> Thanks for ethtool, by the way. It's been helpful in looking at this and
> comparing the eeprom to an earlier version of the board that works.

Eric,

please don't forget that an entire team here at Intel is dedicated to supporting 
e100 and pro/1000 devices from Intel.

Most of the pro/100 features are documented in the SDM which contains some 
references to the eeprom parts. Mostly the device doesn't need much 
configuration from the eeprom to work (unlike gigE parts). The SDM can be 
downloaded from our sf.net project page:

http://sourceforge.net/project/showfiles.php?group_id=42302&package_id=68544

The issue that you are reporting:

"My system boots fine but when I try to bring up the onboard ethernet (an
EEPro 100 VE) I get a "Nobody Cares" message and the interrupt is disabled."

However has been recently patched. This should have worked regardless of whether 
you used e100 or eepro100 (noting that nobody supports eepro100 anymore, you 
should really use e100 for all tests).

if you look in drivers/pci/quirks.c you'll find that there is specific code for 
e100 devices. If this quirk doesn't work for you then we'll need to dig into 
that. For this I'd like you to gather:

- `ethtool -e eth0` output
- `lspci -n` output

this will allow me to check the quirck code and see if it has the right device 
ID. I'm suspecting that the device ID is missing somehow, or the workaround fails.

Auke
