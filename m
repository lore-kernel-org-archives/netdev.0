From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] x86: Drop CONFIG_MCORE2 check around
 setting of NET_IP_ALIGN
Date: Thu, 1 Jul 2010 17:26:54 -0700
Message-ID: <20100701172654.713b6043@nehalam>
References: <20100701232742.15934.49030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Andi Kleen <ak@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54833 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965Ab0GBA06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 20:26:58 -0400
In-Reply-To: <20100701232742.15934.49030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Jul 2010 16:28:27 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch removes the CONFIG_MCORE2 check from around NET_IP_ALIGN.  It is
> based on a suggestion from Andi Kleen.  The assumption is that there are
> not any x86 cores where unaligned access is really slow, and this change
> would allow for a performance improvement to still exist on configurations
> that are not necessarily optimized for Core 2.
> 
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

This is a good idea, but warnig it may end up masking broken
hardware. Developers of new drivers will end up never
exercising unaligned DMA, resulting in hardware 
that doesn't work on platforms that have NET_IP_ALIGN set
to 2.

-- 
