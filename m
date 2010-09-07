From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Tue, 07 Sep 2010 12:38:57 -0700
Message-ID: <1283888337.18468.9.camel@pjaxe>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
	 <20100902065731.GB29972@elte.hu> <20100902100308.GA17167@basil.fritz.box>
	 <20100903063934.GA25863@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100903063934.GA25863@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-02 at 23:39 -0700, Ingo Molnar wrote:
> * Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > This isnt a particularly useful solution to users of said systems - 
> > > they have to figure out that this option exists, and then they have 
> > > to enter this option on the boot line.
> > 
> > This usually only happens in early preproduction systems. So far the 
> > BIOS always got fixed before they shipped to users.
> 
> 'Usually' != 'always'. Read the changelog:
> 
>   ' There are BIOSes in production that have these failures, so this will 
>     allow people in the field to work around these BIOS issues. '
> 
> Peter, which system in production that has this problem? That one needs 
> a DMI match.

It's one SKU of a Nehalem-EX system.  The BIOS for that SKU has an issue
with resolving SRAT hotplug enumeration, and screws up the table.  Other
SKU's of this same platform do not have the issue.  Efforts are underway
to get this BIOS fixed, but in the meantime, there's nothing for users
to work around the bug (aside from disabling memory hotplug in the
BIOS).  Another platform almost shipped with the same symptoms, but
caught it and had it fixed before it shipped (didn't catch it early
because Windows wasn't failing, and most of the testing on that platform
was done under Windows).

I agree with Andi that adding DMI strings would be overkill and would
leave clutter once the BIOS is fixed.  I look at this patch as a
stop-gap measure for people to fall back on until a newer BIOS is
available to correct the NUMA enumeration issues.  Without it, we have
nothing to point users to when they run into this, waiting for a new
BIOS.

Cheers,
-PJ
