From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: intel 82571EB gigabit fails to see link on 2.6.20-rc5 in-tree e1000 driver (regression)
Date: Tue, 16 Jan 2007 11:18:07 -0800
Message-ID: <4807377b0701161118g7f15f201yea4a4c16c252a864@mail.gmail.com>
References: <45AC7CB2.1010202@isohunt.com> <45ACFA96.4040902@isohunt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:17707 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbXAPTSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 14:18:09 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1772798uga
        for <netdev@vger.kernel.org>; Tue, 16 Jan 2007 11:18:08 -0800 (PST)
To: "Allen Parker" <parker@isohunt.com>
In-Reply-To: <45ACFA96.4040902@isohunt.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/07, Allen Parker <parker@isohunt.com> wrote:
> Allen Parker wrote:
> > I have a PCI-E pro/1000 MT Quad Port adapter, which works quite well
> > under 2.6.19.2 but fails to see link under 2.6.20-rc5. Earlier today I
> > reported this to e1000-devel@lists.sf.net, but thought I should get the
> > word out in case someone else is testing this kernel on this nic chipset.

Upon some further investigation with Allen, I got this info, and it
appears that his system is not freeing MSI irq's correctly.

from our discussion:
> Allen wrote:
>> Jesse Brandeburg wrote:
>> I believe you may have an interrupt delivery problem, due to kernel
>> changes.  When you don't get interrupts delivered correctly, you may
>> not achieve link up.
>>
>> you can try disabling CONFIG_PCI_MSI in the kernel, as another
>> trouble shooting step.  Also, what model motherboard/machine are you
>> using, and please check to make sure your BIOS is up to date.
>
> CONFIG_PCI_MSI seems to fix it as well, however, i'm not sure about
> possible performance implications with leaving it turned off.
>
> Tyan S2927G2NR w/ 2x Opteron 2210 bios rev 1.02 iirc

Also, here is an excerpt of his his proc/interrupts
Allen Parker wrote:
       CPU0       CPU1       CPU2       CPU3
498:      1          8        129       8723   PCI-MSI-edge      eth3
499:      0         42        122      17135   PCI-MSI-edge      eth2
500:      0         19        275    1418326   PCI-MSI-edge      eth1
501:      0          0          0          0   PCI-MSI-edge      eth1
502:      0        414         26      25227   PCI-MSI-edge      eth1
503:      0         37        264    1418695   PCI-MSI-edge      eth0
504:      0          0          0        139   PCI-MSI-edge      eth0
505:      0          6        714      22806   PCI-MSI-edge      eth0
NMI:    275        207        225        262
LOC:3531851    3531829    3531805    3531778
ERR:      0

The disturbing bit is that on this Hypertransport to PCIe system, his
interrupts appear to be getting registered multiple times on different
IRQ numbers.

help?
