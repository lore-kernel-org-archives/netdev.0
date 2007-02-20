From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking
 UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 13:02:26 -0800
Message-ID: <20070220130226.7fb80d20@freekitty>
References: <20070219231447.GA4400@outpost.ds9a.nl>
	<p73d545drx6.fsf@bingen.suse.de>
	<20070220162714.GA3245@outpost.ds9a.nl>
	<20070220164124.GA24930@2ka.mipt.ru>
	<20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
	<20070220184859.GA1949@2ka.mipt.ru>
	<20070220193319.GA8800@outpost.ds9a.nl>
	<20070220194040.GA18976@kvack.org>
	<20070220204505.GB8800@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:48955 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030388AbXBTVC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 16:02:57 -0500
In-Reply-To: <20070220204505.GB8800@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Feb 2007 21:45:05 +0100
bert hubert <bert.hubert@netherlabs.nl> wrote:

> On Tue, Feb 20, 2007 at 02:40:40PM -0500, Benjamin LaHaise wrote:
> 
> > Make sure your system is idle.  Userspace bloat means that *lots* of idle 
> > activity occurs in between timer ticks on recent distributions -- all those 
> 
> You hit the nail on the head. I had previously measured with X shut down,
> but the effect didn't disappear.
> 
> With init=/bin/bash, recvfrom suddenly takes from 900nsec to 1.3usec, with
> only slight correlation between inter-call delay and cycles spent.
> 
> I'm investigating this further as it appears this has a real life effect on
> my P4 - a drastic one!
> 
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 15
> model           : 4
> model name      : Intel(R) Pentium(R) 4 CPU 3.00GHz
> stepping        : 1
> cpu MHz         : 3000.131
> cache size      : 1024 KB
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 5
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
> cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx
> constant_tsc pni monitor ds_cpl cid xtpr
> bogomips        : 6003.91
> clflush size    : 64
> 
> Thanks for your help!
> 

What happens with preempt if your process is high priority or SCHED_FIFO/SCHED_RR?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
