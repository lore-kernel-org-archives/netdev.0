From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] drivers/net/tile/: on-chip network drivers for the tile
 architecture
Date: Wed, 3 Nov 2010 13:37:19 -0400
Message-ID: <4CD19DCF.1040709@tilera.com>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com> <20101103125959.3231daa1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([72.1.168.231]:20660 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab0KCRhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 13:37:21 -0400
In-Reply-To: <20101103125959.3231daa1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen, thanks for your feedback!

On 11/3/2010 12:59 PM, Stephen Hemminger wrote:
> 1. MUST not use volatile, see volatile-considered-harmful.txt

The "harmful" use of volatile is in trying to fake out SMP.  Believe me,
with a 64-core architecture, we know our SMP guidelines. :-)  Our use here
is simply to force the compiler to issue a load, for the side-effect of
populating the TLB, for example.

However, your response does suggest that simply the syntactic use of
"volatile" will cause a red flag for readers.  I'll move this to an inline
function in a header with a comment explaining what it's for, and use the
function instead.

> 2. SHOULD use __u32 rather than uint32_t in kernel structures

Thanks, I've made this change in drivers/net/tile/tilepro.c.  In fact, I
used "u32" since this code is not shared with userspace.  However, see
below for the <hv/xxx.h> header files.

> 3. MUST not introduce typedef's; use structures
> 4. SHOULD use proper kernel implementation

(I think you mean proper kernel indentation.)  This is already true for the
kernel sources in driver/net/tile/, but false for the tile-specific
hypervisor headers in arch/tile/include/hv/.  These are "upstream" headers
that are being added to the kernel on an as-needed basis so the kernel can
talk with the hypervisor.

Including a copy of the hypervisor headers with the kernel makes it easier
to build the kernel (since there are no external dependencies that need to
be tracked down to do the build) and is consistent with the fact that we
can in principle modify the hypervisor and its headers out of sync with the
kernel, but still expect the old headers to work correctly with a new
hypervisor since Linux always initializes itself to the hypervisor with the
compiled-in header version number.

So the upshot is that these headers are imported into the kernel and
generally can't be stylistically modified.  But they are "ghettoized" to
arch/tile/include/hv/ and should not cause any trouble. :-)

> If you use scripts/checkpatch.pl it will tell you about these.

Yes, the "volatile" issue is mentioned, but even with "--strict", there's
no mention of uint32_t, so I missed that.  I don't see "uint32" mentioned
anywhere in scripts/checkpatch.pl, in fact.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

