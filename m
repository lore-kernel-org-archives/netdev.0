From: "Adam Kropelin" <akropel1@rochester.rr.com>
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 3 Feb 2007 16:00:02 -0500
Message-ID: <093c01c747d6$45f9a2f0$84163e05@kroptech.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org> <20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com> <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com> <089b01c747be$0ca22620$84163e05@kroptech.com> <45C4F3F1.6060500@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	"Allen Parker" <parker@isohunt.com>, <jesse.brandeburg@intel.com>,
	<gregkh@suse.de>, <linux-pci@atrey.karlin.mff.cuni.cz>,
	<netdev@vger.kernel.org>
To: "Auke Kok" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.nyroc.rr.com ([24.24.2.57]:56073 "EHLO
	ms-smtp-03.nyroc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbXBCVA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 16:00:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Adam Kropelin wrote:
>> I've never had this device work 100% with MSI on any kernel version
>> I've tested so far. But I'm not the original reporter of the
>> problem, and I believe for him it was a true regression where a
>> previous kernel wored correctly.
>
> maybe I've been unclear, but here's how e1000 detects link changes:
>
> 1) by checking every 2 seconds in the watchdog by reading PHY
> registers

That would explain why I see link status changes but 0 interrupt count 
in /proc/interrupts. However, on >= 2.6.19 the link state never changes. 
Ever. It's always down. On <= 2.6.18 the link state does change but with 
0 interupt count.

> 2) by receiving an interrupt from the NIC with the LSI bit
> in the interrupt control register
>
> if the link is down to start with, the watchdog will obviously spot a
> 'link up' change since it doesn't use any interrupts.

This does not seem to work on 2.6.19+. Unless the watchdog interval is 
tens of minutes. I've waited at least 5 minutes and link never went up.

>> The behavior I observe on 2.6.19 is better than 2.6.20-rc7. Link
>> status interrupts seem to work but rx/tx does not. A few more
>> details here:
> <http://www.kroptech.com/~adk0212/mailimport/showmsg.php?msg_id=3339092450&db_name=linux_kernel>
>
>> I'm going to test 2.6.16 thru 2.6.20-rc7 this weekend and will report
>> back any variations in behavior I notice.
>
> that would be a good start, but I still think that you might have a
> broken bridge on that system. Anyway, thanks for digging into this.

Will continue to dig.

--Adam

