From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 13:26:12 -0800
Message-ID: <45C4FDF4.4060002@intel.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
 <20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
 <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
 <089b01c747be$0ca22620$84163e05@kroptech.com> <45C4F3F1.6060500@intel.com>
 <093c01c747d6$45f9a2f0$84163e05@kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
	Allen Parker <parker@isohunt.com>, jesse.brandeburg@intel.com,
	gregkh@suse.de, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org
To: Adam Kropelin <akropel1@rochester.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:49644 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbXBCV1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 16:27:33 -0500
In-reply-to: <093c01c747d6$45f9a2f0$84163e05@kroptech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adam Kropelin wrote:
> Auke Kok wrote:
>> Adam Kropelin wrote:
>>> I've never had this device work 100% with MSI on any kernel version
>>> I've tested so far. But I'm not the original reporter of the
>>> problem, and I believe for him it was a true regression where a
>>> previous kernel wored correctly.
>> maybe I've been unclear, but here's how e1000 detects link changes:
>>
>> 1) by checking every 2 seconds in the watchdog by reading PHY
>> registers
> 
> That would explain why I see link status changes but 0 interrupt count 
> in /proc/interrupts. However, on >= 2.6.19 the link state never changes. 
> Ever. It's always down. On <= 2.6.18 the link state does change but with 
> 0 interupt count.
> 
>> 2) by receiving an interrupt from the NIC with the LSI bit
>> in the interrupt control register
>>
>> if the link is down to start with, the watchdog will obviously spot a
>> 'link up' change since it doesn't use any interrupts.
> 
> This does not seem to work on 2.6.19+. Unless the watchdog interval is 
> tens of minutes. I've waited at least 5 minutes and link never went up.

that's explained by a driver change that did that. Since at initialization we're 
basically waiting for a link change to tell the stack that we're up, we decided 
to change the order to have the hardware fire an LSI interrupt to trigger a 
watchdog run. So no interrupts would immediately explain why the watchdog never 
runs. That's nothing to worry about for this problem, as soon as interrupts are 
seen in /proc/interrupts this all starts working for e1000.

Cheers,

Auke
