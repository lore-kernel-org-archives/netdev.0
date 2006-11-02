From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 2 Nov 2006 10:49:30 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611021042070.1919@math.ut.ee>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
 <20061102.001643.30183952.davem@davemloft.net> <20061102.003953.55508453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:40863 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751353AbWKBIuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 03:50:54 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061102.003953.55508453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Actually, I'm backing this one out, it creates new warnings because
> callers of this function pass in a "const" pointer.

OK, fair enough. Will have a look.

> Please test the complete build when doing warning fixes like
> this in the future, thanks.

Sure. Evenso, I did test full make after the single compile was fine 
(still have it in my scrollback so here it is). So did I do anything 
wrong here or do we have some dependencies broken somewhere or what?
Now that I read the transript again I can see that despite modifying 
include/net/sctp/sm.h nothing was really recompiled - should have 
noticed.

mroos@rhn:~/compile/linux-2.6$ vi net/sctp/sm_make_chunk.c
mroos@rhn:~/compile/linux-2.6$ !make
make net/sctp/sm_make_chunk.o
   CHK     include/linux/version.h
   CHK     include/linux/utsrelease.h
   CC      net/sctp/sm_make_chunk.o
net/sctp/sm_make_chunk.c:1353: error: conflicting types for 'sctp_unpack_cookie'
include/net/sctp/sm.h:279: error: previous declaration of 'sctp_unpack_cookie' was here
make[1]: *** [net/sctp/sm_make_chunk.o] Error 1
make: *** [net/sctp/sm_make_chunk.o] Error 2
mroos@rhn:~/compile/linux-2.6$ vi include/net/sctp/sm.h
mroos@rhn:~/compile/linux-2.6$ make net/sctp/sm_make_chunk.o
   CHK     include/linux/version.h
   CHK     include/linux/utsrelease.h
   CC      net/sctp/sm_make_chunk.o
mroos@rhn:~/compile/linux-2.6$ make
   CHK     include/linux/version.h
   CHK     include/linux/utsrelease.h
   CHK     include/linux/compile.h
   MODPOST vmlinux
Kernel: arch/i386/boot/bzImage is ready  (#274)
   Building modules, stage 2.
   MODPOST 511 modules
mroos@rhn:~/compile/linux-2.6$ cg-diff  > ~/sctppatch


-- 
Meelis Roos (mroos@linux.ee)
