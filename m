From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Tue, 07 Sep 2010 13:03:47 -0700
Message-ID: <4C869AA3.6000103@zytor.com>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>	 <20100902065731.GB29972@elte.hu> <20100902100308.GA17167@basil.fritz.box>	 <20100903063934.GA25863@elte.hu> <1283888337.18468.9.camel@pjaxe>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:42250 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754645Ab0IGUEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 16:04:36 -0400
In-Reply-To: <1283888337.18468.9.camel@pjaxe>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2010 12:38 PM, Peter P Waskiewicz Jr wrote:
> 
> It's one SKU of a Nehalem-EX system.  The BIOS for that SKU has an issue
> with resolving SRAT hotplug enumeration, and screws up the table.  Other
> SKU's of this same platform do not have the issue.  Efforts are underway
> to get this BIOS fixed, but in the meantime, there's nothing for users
> to work around the bug (aside from disabling memory hotplug in the
> BIOS).  Another platform almost shipped with the same symptoms, but
> caught it and had it fixed before it shipped (didn't catch it early
> because Windows wasn't failing, and most of the testing on that platform
> was done under Windows).
> 
> I agree with Andi that adding DMI strings would be overkill and would
> leave clutter once the BIOS is fixed.  I look at this patch as a
> stop-gap measure for people to fall back on until a newer BIOS is
> available to correct the NUMA enumeration issues.  Without it, we have
> nothing to point users to when they run into this, waiting for a new
> BIOS.
> 

No, this is exactly the kind of stuff for which a DMI match is ideal.  A
specific system with bounded propagation of the problem.  Thus, the DMI
match acts as a whitelist -- "we know this system and it is safe to
activate this hack on it."  This is a very good thing.

If this is a production BIOS it should have this information.

	-hpa
