From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [regression] e1000e broke e1000
Date: Wed, 09 Apr 2008 20:52:05 -0400
Message-ID: <47FD64B5.1050309@tmr.com>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>	<20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756522AbYDJAsb@vger.kernel.org>
In-Reply-To: <20080408195123.GA28148@elte.hu>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Matthew Wilcox <matthew@wil.cx> wrote:
> 
>> On Tue, Apr 08, 2008 at 08:39:21PM +0200, Ingo Molnar wrote:
>>> so the pure presence of the e1000e module breaks the e1000 driver. That 
>>> is a regression and a bug that should be fixed.
>> I think you've found the wrong problem ... it looks deliberate to me 
>> that enabling e1000e disables e1000 from claiming the PCI IDs (see the 
>> PCIE() macro right before the e1000_pci_tbl in 
>> drivers/net/e1000/e1000_main.c).
>>
>> The question is why e1000e isn't claiming the device ...
> 
> because i have e1000 built-in and dont load the e1000e module at all. 
> That worked before and doesnt work now.
> 
> the solution is rather straightforward: if E1000 is built-in then E1000E 
> should be built-in as well or disabled (i.e. it should not be possible 
> to build it as a module in that case) - because the PCI ID stealing 
> trick now connects the two drivers unconditionally. [ If e1000 is a 
> module then e1000e can be a module (or disabled) - this would be the 
> most common configuration. ]
> 
And this would seem to break the most common means of testing a new 
driver for existing (and working!) hardware, which is to build both 
drivers as modules, install the new one, and if it appears to have 
problems either remove and insert the old driver by hand, or boot 
forcing the old driver.

I can't be the only person who tests kernels on machines I wouldn't use 
to build a kernel, and uses modprobe.conf to test new driver functionality.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
