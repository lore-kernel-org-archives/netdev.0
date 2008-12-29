From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 21:31:54 +1100
Message-ID: <20081229103154.GA9691@gondor.apana.org.au>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com> <20081225112658.GA7260@gondor.apana.org.au> <1230300535.9487.292.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com> <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54416 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752509AbYL2KcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 05:32:02 -0500
Content-Disposition: inline
In-Reply-To: <1230544927.16718.12.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 11:02:07AM +0100, Peter Zijlstra wrote:
>
> Subject: net: fix tcp deadlock
> 
> Lockdep spotted that the percpu counter op takes a lock so that softirq
> recursion deadlocks can occur. Delay the op until we've disabled
> softirqs to avoid this.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

You also need to patch the other places where we use that percpu
counter from process context, e.g., for /proc/net/tcp.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
