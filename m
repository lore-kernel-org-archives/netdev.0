From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Thu, 2 Sep 2010 08:57:31 +0200
Message-ID: <20100902065731.GB29972@elte.hu>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org, andi@firstfloor.org,
	netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:55070 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab0IBG5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 02:57:42 -0400
Content-Disposition: inline
In-Reply-To: <20100901213318.19353.54619.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:

> On certain BIOSes, SRAT enumeration isn't exported correctly. This 
> leads to NUMA node enumeration failure, and causes the kernel to fall 
> back onto a single node treated as flat memory.  This can happen on 
> large, multi-socket systems (4 or more sockets), and becomes 
> problematic for performance.
> 
> This patch adds a boot parameter to allow a kernel to be booted with 
> the option to skip the SRAT check.  There are BIOSes in production 
> that have these failures, so this will allow people in the field to 
> work around these BIOS issues.

> + 	sratbypassbios
> +		If specified, will skip an SRAT check for PXM coverage
> +		from BIOS enumeration.  Only to be used on systems with
> +		buggy BIOSes that munge the SRAT enumeration.

This isnt a particularly useful solution to users of said systems - they 
have to figure out that this option exists, and then they have to enter 
this option on the boot line.

A better solution would be to match these systems using DMI filters - 
_and_ to also have the boot time option to cover the case where a new 
system comes out with such a breakage. (or there's some system not yet 
mapped)


	Ingo
