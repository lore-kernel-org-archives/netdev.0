From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [stable] net: Handle different key sizes between address
 families in flow cache
Date: Fri, 4 Nov 2011 21:29:58 -0500
Message-ID: <20111104212958.5d54152b38050e2a0917d575@freescale.com>
References: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
	<20111101.203430.110242050755204948.davem@davemloft.net>
	<20111103135851.2229247682ec040d653479e1@freescale.com>
	<20111103.224329.2276058062630695656.davem@davemloft.net>
	<20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
	<20111104212439.GA27324@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <stable@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <zheng.z.yan@intel.com>,
	<netdev@vger.kernel.org>, David Ward <david.ward@ll.mit.edu>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:30102
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752180Ab1KECa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 22:30:58 -0400
In-Reply-To: <20111104212439.GA27324@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Nov 2011 14:24:39 -0700
Greg KH <greg@kroah.com> wrote:

> On Fri, Nov 04, 2011 at 02:46:59PM -0500, Kim Phillips wrote:
> > commit aa1c366e4febc7f5c2b84958a2dd7cd70e28f9d0 upstream.
> > 
> > With the conversion of struct flowi to a union of AF-specific structs, some
> > operations on the flow cache need to account for the exact size of the key.
> > 
> > Signed-off-by: David Ward <david.ward@ll.mit.edu>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > Cc: stable@vger.kernel.org # v3.0.x
> > ---
> > This patch is the result of a clean cherry-pick onto v3.0.8.
> > It restores IPSec fwding performance from ~4kpps back to ~44kpps on
> > a P2020DS board.
> 
> Too bad you forgot to build this patch after you applied it:
>   CC      init/main.o
> In file included from include/linux/security.h:39:0,
>                  from init/main.c:32:
> include/net/flow.h: In function 'flow_key_size':
> include/net/flow.h:174:3: error: size of unnamed array is negative
> include/net/flow.h:177:3: error: size of unnamed array is negative
> 
> Please be kind to your poor over-worked stable kernel maintainer and do
> the decent thing and TEST YOUR PATCH before you ask him to accept it.
> 
> bah, I think it's time for the weekend to start a bit earlier than normal...

so sorry I hadn't tested 64-bit.

I found the problem - upstream commit aa1c366 depends on
upstream commit 728871b:

commit 728871bc05afc8ff310b17dba3e57a2472792b13
Author: David Ward <david.ward@ll.mit.edu>
Date:   Mon Sep 5 16:47:23 2011 +0000

    net: Align AF-specific flowi structs to long
    
    AF-specific flowi structs are now passed to flow_key_compare, which must
    also be aligned to a long.
    
    Signed-off-by: David Ward <david.ward@ll.mit.edu>
    Signed-off-by: David S. Miller <davem@davemloft.net>

so, one more time, in stable sign-off area format:

Cc: <stable@vger.kernel.org> # v3.0.x: 728871b: net: Align AF-specific flowi structs to long
Cc: <stable@vger.kernel.org> # v3.0.x

build tested on 32- and 64-bit powerpc, and ARCH=x86
{i386,x86_64}_defconfig.

Kim
