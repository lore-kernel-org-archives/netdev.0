From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Tue, 4 Sep 2007 09:12:09 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520344439B@orsmsx418.amr.corp.intel.com>
References: <46DD8014.7000408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-net@vger.kernel.org>
To: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Marc Sigler" <marc.sigler@mediatvcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25442 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867AbXIDQML convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 12:12:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46DD8014.7000408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Marc Sigler wrote:
>> Hello everyone,
>> 
>> I have several systems with three integrated Intel 82559 (I *think*).
>> 
>> Does someone know if these boards support hardware interrupt
>> mitigation? I.e. is it possible to configure them to raise an IRQ
>> only if their hardware buffer is full OR if some given time (say 1
>> ms) has passed and packets are available in their hardware buffer.
>> 
>> I've been using the eepro100 driver up to now, but I'm about to try
>> the e100 driver. Would I have to use NAPI? Or is this an orthogonal
>> feature? 
> 
> the software developers manual for this part is available on our
> e1000.sf.net page here:
> 
>
http://downloads.sourceforge.net/e1000/OpenSDM_55x_10c.pdf?modtime=10400
83200&big_mirror=0
> 
> e100 hardware (as far as I can see from the specs) doesn't support
> any irq mitigation, so you'll need to run in NAPI mode if you want to
> throttle irq's. the in-kernel e100 already runs in NAPI mode, so
> that's already covered. 
> 
> beware that the eepro100 driver is scheduled for removal (2.6.25 or
> so). 

We support mitigation of interrupts in a downloadable microcode on only
a few pieces of hardware (revision id specific) in e100.c (see
e100_setup_ucode)

If you really really wanted mitigation you could probably backport the
microcode from the e100 driver in the 2.4.35 kernel for your specific
hardware.  This driver is versioned 2.X.

Beyond that I can't really offer much help in this case, but would
certainly accept patches!

Jesse
