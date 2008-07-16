From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Wed, 16 Jul 2008 12:03:41 +0200
Message-ID: <87bq0y2lj6.fsf@macbook.be.48ers.dk>
References: <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org>
	<20080429153240.7200e1a3.akpm@linux-foundation.org>
	<4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com>
	<483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com>
	<483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com>
	<487D2236.9000903@garzik.org> <20080715223626.GA10532@redhat.com>
	<487D2AEE.8030309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:19456 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbYGPKDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:03:47 -0400
Received: by ug-out-1314.google.com with SMTP id h2so488371ugf.16
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 03:03:45 -0700 (PDT)
In-Reply-To: <487D2AEE.8030309@garzik.org> (Jeff Garzik's message of "Tue\, 15 Jul 2008 18\:55\:42 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jeff" == Jeff Garzik <jeff@garzik.org> writes:

 >> > * [optional] if code not too ugly, change mod param description
 >> based on  > CONFIG_8139TOO_PIO to indicate the currently compiled
 >> default
 >> 
 >> Not sure of a non-icky way to do this other than ifdefs.
 >> The best I could come up with is.
 >> 
 >> #ifdef CONFIG_8139TOO_PIO
 >> MODULE_PARM_DESC(use_io, "PIO/MMIO switch.  0=MMIO 1=PIO
 >> default=PIO"); #else
 >> MODULE_PARM_DESC(use_io, "PIO/MMIO switch.  0=MMIO 1=PIO
 >> default=MMIO"); #endif
 >> 
 >> palatable?

 Jeff> best you can do AFAIK, so yes

Something like:
#ifdef CONFIG_8139TOO_PIO
#define DEFAULTMODE "PIO"
#else
#define DEFAULTMODE "MMIO"
#endif

MODULE_PARM_DESC(use_io, "PIO/MMIO switch.  0=MMIO 1=PIO default=" DEFAULTMODE);

would be nicer.

-- 
Bye, Peter Korsgaard
