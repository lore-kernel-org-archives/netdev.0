From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Tue, 7 Sep 2010 21:56:27 +0200
Message-ID: <20100907195627.GA16387@elte.hu>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
 <20100902065731.GB29972@elte.hu>
 <20100902100308.GA17167@basil.fritz.box>
 <20100903063934.GA25863@elte.hu>
 <1283888337.18468.9.camel@pjaxe>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283888337.18468.9.camel@pjaxe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:

> On Thu, 2010-09-02 at 23:39 -0700, Ingo Molnar wrote:
> > * Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > > This isnt a particularly useful solution to users of said systems - 
> > > > they have to figure out that this option exists, and then they have 
> > > > to enter this option on the boot line.
> > > 
> > > This usually only happens in early preproduction systems. So far the 
> > > BIOS always got fixed before they shipped to users.
> > 
> > 'Usually' != 'always'. Read the changelog:
> > 
> >   ' There are BIOSes in production that have these failures, so this will 
> >     allow people in the field to work around these BIOS issues. '
> > 
> > Peter, which system in production that has this problem? That one needs 
> > a DMI match.
> 
> It's one SKU of a Nehalem-EX system.  The BIOS for that SKU has an 
> issue with resolving SRAT hotplug enumeration, and screws up the 
> table.  Other SKU's of this same platform do not have the issue.  
> Efforts are underway to get this BIOS fixed, but in the meantime, 
> there's nothing for users to work around the bug (aside from disabling 
> memory hotplug in the BIOS).  Another platform almost shipped with the 
> same symptoms, but caught it and had it fixed before it shipped 
> (didn't catch it early because Windows wasn't failing, and most of the 
> testing on that platform was done under Windows).
>
> I agree with Andi that adding DMI strings would be overkill and would 
> leave clutter once the BIOS is fixed. [...]

We use the following policy for hardware/firmware workarounds in 
upstream arch/x86: if the system got shipped and if the vendor/OEM wants 
it fixed, then it has real DMI info (or some PCI ID match method, etc.) 
and an automatic workaround is very well possible and desirable.

If the vendor cannot be bothered to add a few lines based on a simple 
reading of dmidecode output and test it, then we dont really want/need 
the rest of the patch upstream either.

It should be literally 5 minutes of work to add a DMI match.

> I look at this patch as a stop-gap measure for people to fall back on 
> until a newer BIOS is available to correct the NUMA enumeration 
> issues. [...]

We dont do half-done stop-gap measures in the upstream kernel like that, 
and for various good reasons.

Furthermore, since Windows doesnt have a problem booting with this, i'm 
afraid that we are bound to see repeat problems of this sort, so we 
better have the DMI path beaten out - even if in this case it's a single 
model.

> [...]  Without it, we have nothing to point users to when they run 
> into this, waiting for a new BIOS.

I by all means support you to give users a real fix - one that applies 
the workaround automatically with a DMI match. Also, as i said, we can 
also add the boot option in the same patch.

Thanks,

	Ingo
