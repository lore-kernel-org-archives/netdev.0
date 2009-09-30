From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH,TRIVIAL] Fix csum_ipv6_magic asm memory clobber
Date: Wed, 30 Sep 2009 16:19:39 -0700
Message-ID: <20090930161939.8c6d140a.akpm@linux-foundation.org>
References: <20090926192748.GX7681@const.famille.thibault.fr>
	<20090930154044.0c7ace16.akpm@linux-foundation.org>
	<4AC3DF7B.5060407@zytor.com>
	<20090930230138.GZ6451@const.famille.thibault.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, linux-kernel@vger.kernel.org, mingo@elte.hu,
	tglx@linutronix.de, davem@davemloft.net, andi@firstfloor.org,
	netdev@vger.kernel.org
To: Samuel Thibault <samuel.thibault@ens-lyon.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35910 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754630AbZI3XUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:20:18 -0400
In-Reply-To: <20090930230138.GZ6451@const.famille.thibault.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009 01:01:38 +0200
Samuel Thibault <samuel.thibault@ens-lyon.org> wrote:

> Actually it hit Hurd's pfinetv4 when we tried to compile it with
> gcc-4.3 (bogus checksums).

That's important information!  I updated the changelog and added the
Cc:stable, thanks.


Full patch for netdev benefit:


From: Samuel Thibault <samuel.thibault@ens-lyon.org>

Just like ip_fast_csum, the assembly snippet in csum_ipv6_magic needs a
memory clobber, as it is only passed the address of the buffer, not a
memory reference to the buffer itself.

This caused failures in Hurd's pfinetv4 when we tried to compile it with
gcc-4.3 (bogus checksums).

Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/include/asm/checksum_32.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/checksum_32.h~x86-fix-csum_ipv6_magic-asm-memory-clobber arch/x86/include/asm/checksum_32.h
--- a/arch/x86/include/asm/checksum_32.h~x86-fix-csum_ipv6_magic-asm-memory-clobber
+++ a/arch/x86/include/asm/checksum_32.h
@@ -161,7 +161,8 @@ static inline __sum16 csum_ipv6_magic(co
 	    "adcl $0, %0	;\n"
 	    : "=&r" (sum)
 	    : "r" (saddr), "r" (daddr),
-	      "r" (htonl(len)), "r" (htonl(proto)), "0" (sum));
+	      "r" (htonl(len)), "r" (htonl(proto)), "0" (sum)
+	    : "memory");
 
 	return csum_fold(sum);
 }
_

