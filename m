From: "Adam Kropelin" <akropel1@rochester.rr.com>
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 3 Feb 2007 13:06:38 -0500
Message-ID: <089b01c747be$0ca22620$84163e05@kroptech.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org> <20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com> <m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	"Allen Parker" <parker@isohunt.com>, <jesse.brandeburg@intel.com>,
	<gregkh@suse.de>, <linux-pci@atrey.karlin.mff.cuni.cz>,
	<ebiederm@xmission.com>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Auke Kok" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.nyroc.rr.com ([24.24.2.57]:57989 "EHLO
	ms-smtp-03.nyroc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbXBCSH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 13:07:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Auke Kok <auke-jan.h.kok@intel.com> writes:
>> None of the MSI code in e1000 has changed significantly either. as
>> far as I can see, the msi code in e1000 has not changed since
>> 2.6.18. Nonetheless there's no way I can debug any of this without a
>> system.
>> [...]
>> Perhaps Adam can git-bisect this issue? Adam?
>
> Do we have any explanation about the weird /proc/interrupts output?
> i.e. Multiple MSI irqs being assigned to the same card?
>
> Does /sbin/ifconfig ethN down ; /sbin/ifconfig ethN up have anything
> to do with the duplication in /proc/interrupts?
>
> I can't see any way for a pci device that doesn't support msi-x to be
> assigned multiple interrupts simultaneously.
>
> I just skimmed through the code and there hasn't been any significant
> generic MSI work since 2.6.19.
>
> Did this device really work with MSI enabled in 2.6.19?

I've never had this device work 100% with MSI on any kernel version I've 
tested so far. But I'm not the original reporter of the problem, and I 
believe for him it was a true regression where a previous kernel wored 
correctly.

The behavior I observe on 2.6.19 is better than 2.6.20-rc7. Link status 
interrupts seem to work but rx/tx does not. A few more details here:
<http://www.kroptech.com/~adk0212/mailimport/showmsg.php?msg_id=3339092450&db_name=linux_kernel>

I'm going to test 2.6.16 thru 2.6.20-rc7 this weekend and will report 
back any variations in behavior I notice.

--Adam

