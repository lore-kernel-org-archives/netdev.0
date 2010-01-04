From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH -v2] x86: increase NR_IRQS and nr_irqs
Date: Sun, 03 Jan 2010 19:20:19 -0800
Message-ID: <4B415E73.1050801@kernel.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	 <4B398ECD.1080506@kernel.org> <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35803 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834Ab0ADDVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jan 2010 22:21:45 -0500
In-Reply-To: <4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/2010 07:06 PM, Jesse Brandeburg wrote:
> On Mon, Dec 28, 2009 at 9:08 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>> have a system with lots of igb and ixgbe, when iov/vf are enabled for
>> them, we hit the limit of 3064.
>>
>> when system have 20 pcie installed, and one card have 2 functions, and one
>> function need 64 msi-x,
>>  may need 20 * 2 * 64 = 2560 for msi-x
>> but if iov and vf are enabled
>>  may need 20 * 2 * 64 * 3 = 7680 for msi-x
>> assume system with 5 ioapic, nr_irqs_gsi will be 120.
>> NR_CPUS = 512, and nr_cpu_ids = 128
>> will have NR_IRQS = 256 + 512 * 64 = 33024
>> will have nr_irqs = 120 + 8 * 128 + 120 * 64 = 8824
>>
>> when SPARSE_IRQ is not set, there is no increase with data
>> when NR_CPUS=128, and SPARSE_IRQ is set
>>   text            data     bss            dec           hex    filename
>> 21837444        4216564 12480736        38534744        24bfe58 vmlinux.before
>> 21837442        4216580 12480736        38534758        24bfe66 vmlinux.after
>> when NR_CPUS=4096, and SPARSE_IRQ is set
>>   text            data     bss            dec           hex    filename
>> 21878619        5610244 13415392        40904255        270263f vmlinux.before
>> 21878617        5610244 13415392        40904253        270263d vmlinux.after
>>
>> -v2: update comments to address Ingo's concern
>>
>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> 
> I'm not sure this is the best plan, but may be okay for now.  What
> happens when all of your slots have 6 port 82599 ixgbe adapters in
> them?  They are being made[1], as well as quad port 82576 igb
> adapters, however I'm not fully sure of the SRIOV support of the
> bridges being used on those adapters.
> 
> Is it on the table to (re-)design this subsystem to be a little more
> dynamic?  There are probably examples in ppc64 or ia64 directories.
> Every time you suggest a limit I can find a case where it won't be
> enough.
> 
> [1] http://www.hotlavasystems.com/products_10gbe.html

you mean
20 * 6 * 64 * 3 ?

23040

maybe we can just keep nr_irqs = (256 - 32 - 10) * nr_cpu_ids?
32: for exception
10: for IPI etc.

YH
