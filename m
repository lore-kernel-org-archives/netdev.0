From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 27 Jan 2009 16:17:56 -0800
Message-ID: <57C9024A16AD2D4C97DC78E552063EA35F317617@orsmsx505.amr.corp.intel.com>
References: <200901271213.18605.rusty@rustcorp.com.au>
	<497E705B.5000302@kernel.org>	<alpine.DEB.1.10.0901271506580.3114@qirst.com>
 <20090127.134747.153565246.davem@davemloft.net> <497F8F02.9000603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>,
	"tj@kernel.org" <tj@kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"brgerst@gmail.com" <brgerst@gmail.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"travis@sgi.com" <travis@sgi.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"steiner@sgi.com" <steiner@sgi.com>,
	"hugh@veritas.com" <hugh@veritas.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62530 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbZA1AR6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:17:58 -0500
In-Reply-To: <497F8F02.9000603@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I was asking around, and was told that on IA64 *harware* at least, in addition to
> supporting multiple page sizes (up to a GB IIRC), one can pin up to 8 or perhaps
> 1/2 the TLB entries.

The number of TLB entries that can be pinned is model specific (but the
minimum allowed is 8 each for code & data).  Page sizes supported also
vary by model, recent models go up to 4GB.

BUT ... we stopped pinning this entry in the TLB when benchmarks showed
that it was better to just insert this as a regular TLB entry which might
can be dropped to map something else.  So now there is code in the Alt-DTLB
miss handler (ivt.S) to insert the per-cpu mapping on an as needed basis.

> So, in theory if one were so inclined the special pinned per-CPU entry could
> either be more than one 64K entry, or a single, rather larger entry.

Managing a larger space could be done ... but at the expense of making
the Alt-DTLB miss handler do a memory lookup to find the physical address
of the per-cpu page needed (assuming that we allocate a bunch of random
physical pages for use as per-cpu space rather than a single contiguous
block of physical memory).

When do we know the total amount of per-cpu memory needed?
1) CONFIG time?
2) Boot time?
3) Arbitrary run time?

-Tony
