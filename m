From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 12:43:29 -0800
Message-ID: <45C4F3F1.6060500@intel.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org> <20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com> <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com> <089b01c747be$0ca22620$84163e05@kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
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
Received: from mga01.intel.com ([192.55.52.88]:6521 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbXBCUnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Feb 2007 15:43:32 -0500
In-Reply-To: <089b01c747be$0ca22620$84163e05@kroptech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adam Kropelin wrote:
 > Eric W. Biederman wrote:
 >> Auke Kok <auke-jan.h.kok@intel.com> writes:
 >>> None of the MSI code in e1000 has changed significantly either. as
 >>> far as I can see, the msi code in e1000 has not changed since
 >>> 2.6.18. Nonetheless there's no way I can debug any of this without a
 >>> system.
 >>> [...]
 >>> Perhaps Adam can git-bisect this issue? Adam?
 >> Do we have any explanation about the weird /proc/interrupts output?
 >> i.e. Multiple MSI irqs being assigned to the same card?
 >>
 >> Does /sbin/ifconfig ethN down ; /sbin/ifconfig ethN up have anything
 >> to do with the duplication in /proc/interrupts?
 >>
 >> I can't see any way for a pci device that doesn't support msi-x to be
 >> assigned multiple interrupts simultaneously.
 >>
 >> I just skimmed through the code and there hasn't been any significant
 >> generic MSI work since 2.6.19.
 >>
 >> Did this device really work with MSI enabled in 2.6.19?
 >
 > I've never had this device work 100% with MSI on any kernel version I've
 > tested so far. But I'm not the original reporter of the problem, and I
 > believe for him it was a true regression where a previous kernel wored
 > correctly.

maybe I've been unclear, but here's how e1000 detects link changes:

1) by checking every 2 seconds in the watchdog by reading PHY registers
2) by receiving an interrupt from the NIC with the LSI bit in the interrupt 
control register

if the link is down to start with, the watchdog will obviously spot a 'link up' 
change since it doesn't use any interrupts.

The link interrupt (LSI) is a generic interrupt that comes over the same vector 
(be it MSI or not) as RX interrupts, and in your case doesn't arrive at all, 
which should be demonstrateable if you set e.g. the watchdog interval to 30 
seconds and unplug the cable - the driver won't spot the link change until the 
watchdog fires a lot later than you unplugged the cable.

 > The behavior I observe on 2.6.19 is better than 2.6.20-rc7. Link status
 > interrupts seem to work but rx/tx does not. A few more details here:
 > 
<http://www.kroptech.com/~adk0212/mailimport/showmsg.php?msg_id=3339092450&db_name=linux_kernel>

 > I'm going to test 2.6.16 thru 2.6.20-rc7 this weekend and will report
 > back any variations in behavior I notice.

that would be a good start, but I still think that you might have a broken 
bridge on that system. Anyway, thanks for digging into this.

Auke
