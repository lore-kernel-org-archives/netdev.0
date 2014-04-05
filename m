From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/6] net: Allow csum_add to be provided in arch
Date: Fri, 04 Apr 2014 18:34:51 -0700
Message-ID: <1396661691.12330.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1404041714560.20552@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:60883 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbaDEBep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 21:34:45 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so4235108pad.3
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 18:34:45 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1404041714560.20552@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-04 at 17:26 -0700, Tom Herbert wrote:
> csum_add is really nothing more then add-with-carry which
> can be implemented efficiently in some architectures.
> Allow architecture to define this protected by HAVE_ARCH_CSUM_ADD.
> 
> Provide csum_add in for x86.

[ net-next is closed during merge window ]

Not x86, but x86_64 only.

Note add32_with_carry(a, b) is suboptimal, as it forces
a and b in registers.

b could be a memory or a register operand.

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a026c7b..29f130d3c344 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -184,7 +184,7 @@ static inline unsigned add32_with_carry(unsigned a, unsigned b)
        asm("addl %2,%0\n\t"
            "adcl $0,%0"
            : "=r" (a)
-           : "0" (a), "r" (b));
+           : "0" (a), "rm" (b));
        return a;
 }
