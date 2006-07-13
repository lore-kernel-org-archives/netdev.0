From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 fails to load sometimes: The EEPROM Checksum Is Not Valid
Date: Thu, 13 Jul 2006 11:47:33 -0700
Message-ID: <44B69545.8000507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31301 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030291AbWGMS5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 14:57:07 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>,
	profilek@users.sourceforge.net, squat@users.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > With 2.6.17-rc5-mm2 (and other kernels), the e1000 fails to load
 > sometimes, with the message:
 >
 > Intel(R) PRO/1000 Network Driver - version 7.0.38-k4-NAPI
 > Copyright (c) 1999-2006 Intel Corporation.
 > ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 20
 > PCI: Setting latency timer of device 0000:02:00.0 to 64
 > e1000: 0000:02:00.0: e1000_probe: The EEPROM Checksum Is Not Valid
 > e1000: probe of 0000:02:00.0 failed with error -5
 >
 > Sometimes it will do this after several modprobe/rmmod cycles, and then
 > it will load OK.  Once loaded, it seems to work perfectly.


Sorry for the long wait, there's some new information on this that just this 
morning arrived.

We received reports from SuSE that on a T60 they were seeing the same problem. 
After obtaining a T60 ourselves we managed to spot the suspected problem: it 
is related to the "smart power down" capability of the PHY. Lenovo had this 
feature turned on in certain BIOS'es which caused the EEPROM reads to fail.

Some people reported that the problem goes away when you plug in a cable - 
this guarantees that the PHY is turned on and probably masks the issue for a 
lot of people (either you work plugged in or forget about the NIC when you 
work wireless, thus not seeing the issue).

The latest EEPROM's from Lenovo (obtainable from their websites as .iso) seem 
to have this feature turned off, which resolves the issue.

We're right now working on seeing if we can find a workaround for the issue 
ourselves in the driver, but in any case you can always try to grab the latest 
BIOS from lenovo's website, and tell us if that works for you.

meanwhile we're working on a more permanent solution.

Cheers,

Auke



Refs:
http://sourceforge.net/tracker/index.php?func=detail&aid=1474679&group_id=42302&atid=447449
http://forums.gentoo.org/viewtopic-t-476305-highlight-e1000.html
