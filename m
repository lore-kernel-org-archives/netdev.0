From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 14:12:39 -0700
Message-ID: <m1ejp70wu0.fsf@ebiederm.dsl.xmission.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
	<20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
	<m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
	<089b01c747be$0ca22620$84163e05@kroptech.com>
	<45C4F3F1.6060500@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adam Kropelin <akropel1@rochester.rr.com>,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
	Allen Parker <parker@isohunt.com>, jesse.brandeburg@intel.com,
	gregkh@suse.de, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43223 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbXBCVOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 16:14:09 -0500
In-Reply-To: <45C4F3F1.6060500@intel.com> (Auke Kok's message of "Sat, 03 Feb
	2007 12:43:29 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> writes:

> maybe I've been unclear, but here's how e1000 detects link changes:
>
> 1) by checking every 2 seconds in the watchdog by reading PHY registers
> 2) by receiving an interrupt from the NIC with the LSI bit in the interrupt
> control register
>
> if the link is down to start with, the watchdog will obviously spot a 'link up'
> change since it doesn't use any interrupts.
>
> The link interrupt (LSI) is a generic interrupt that comes over the same vector
> (be it MSI or not) as RX interrupts, and in your case doesn't arrive at all,
> which should be demonstrateable if you set e.g. the watchdog interval to 30
> seconds and unplug the cable - the driver won't spot the link change until the
> watchdog fires a lot later than you unplugged the cable.
>
>> The behavior I observe on 2.6.19 is better than 2.6.20-rc7. Link status
>> interrupts seem to work but rx/tx does not. A few more details here:
>>
> <http://www.kroptech.com/~adk0212/mailimport/showmsg.php?msg_id=3339092450&db_name=linux_kernel>
>
>> I'm going to test 2.6.16 thru 2.6.20-rc7 this weekend and will report
>> back any variations in behavior I notice.
>
> that would be a good start, but I still think that you might have a broken
> bridge on that system. Anyway, thanks for digging into this.

Right.  The basic question is on a problem system are MSI interrupts
from the card in /proc/interrupts observed.  If interrupts are not
observed (as it sounds like is the case) it is most likely something
outside of the card, and driver.  If interrupts are observed but the
card does not work correctly it could be a card or driver bug.

Ok.  In the archives I finally found the output of cat
/proc/interrupts and there were none.

This is a PCI-E to Hypertransport system from the lspci output.

Can I get the corresponding lspci -xxx output.  I suspect the BIOS
did not program the hypertransport MSI mapping capabilities correctly.
All it has to do is set the enable but still, occasionally BIOS
writers miss the most amazing things.

If that is the case with just a little creativity we should be able to
write a pci quirk that will enable the MSI mapping capability on this
class of systems and save ourselves a lot of trouble.

Although I thought I did see a quirk that disabled MSI if the enable
bit was not set.  Hmm.

Anyway please the lspci -xxx output.  Although if someone could teach
lspci to decode the hypertransport MSI mapping capability so that
lspic -vvv gave us this information that would be great too.

Eric
