From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [BUILD-FAILURE] next-20091015 - vbus_enet driver breaks
	 with allmodconfig
Date: Fri, 06 Nov 2009 12:02:41 -0700
Message-ID: <4AF42C810200005A00058361@sinclair.provo.novell.com>
References: <20091015152538.74a1cb15.sfr@canb.auug.org.au>
 <20091015104852.GA6740@linux.vnet.ibm.com>
 <4AD6CD940200005A00056857@sinclair.provo.novell.com>
 <4AD75E60.4020306@gmail.com>
 <20091015114210.65e1be72.randy.dunlap@oracle.com>
 <4AD7A141.3060102@gmail.com>
 <20091106093856.e9eac13e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <sfr@canb.auug.org.au>, <greg@kroah.com>,
	"Kamalesh Babulal" <kamalesh@linux.vnet.ibm.com>,
	"LKML" <linux-kernel@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Gregory Haskins" <gregory.haskins@gmail.com>,
	"Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091106093856.e9eac13e.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 11/6/2009 at 12:38 PM, in message
<20091106093856.e9eac13e.randy.dunlap@oracle.com>, Randy Dunlap
<randy.dunlap@oracle.com> wrote: 
> On Thu, 15 Oct 2009 18:25:05 -0400 Gregory Haskins wrote:
> 
>> Randy Dunlap wrote:
>> > On Thu, 15 Oct 2009 13:39:44 -0400 Gregory Haskins wrote:
>> > 
>> >>
>> >> I am having difficulty reproducing the problem.  When I look at the
>> >> Kconfig, I see that VBUS_ENET has a "select VBUS_PROXY" as I would
>> >> expect.  Additionally, if I run allmodconfig I can confirm that I get
>> >> VBUS_ENET=m, VBUS_PROXY=y:
>> > 
>> > Greg,
>> > 
>> > Did you try to reproduce it with the ppc64 config file?
>> > allmodconfig on what arch?
>> > 
>> > I think the problem is that arch/x86/Kconfig says:
>> > 
>> > source "drivers/vbus/Kconfig"
>> > 
>> > and that should actually be in drivers/Kconfig, so that it applies
>> > to ppc64 et al, not just x86.
>> 
>> Ah, indeed.  I only have/tried x86, and that is the issue.  I will have
>> to fix this (and the create_irq() dependency you mention in the next mail).
> 
> Hi Greg,
> 
> I'm still getting
> pci-bridge.c:(.text+0x31b633): undefined reference to `create_irq'
> 
> on today's linux-next-20091106.
> CONFIG_SMP=n
> CONFIG_X86_UP_APIC=n
> 
> full config attached.
> 
> 
> ---
> ~Randy

Indeed.  Looks like I need to be smarter about how the create_irq facility is used.  I will fix this. 

Thanks Randy,
-Greg
