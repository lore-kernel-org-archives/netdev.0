From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 09:15:08 -0800
Message-ID: <57C9024A16AD2D4C97DC78E552063EA35F317910@orsmsx505.amr.corp.intel.com>
References: <200901271213.18605.rusty@rustcorp.com.au>
 <497E705B.5000302@kernel.org> <alpine.DEB.1.10.0901271506580.3114@qirst.com>
 <20090127.134747.153565246.davem@davemloft.net> <497F8F02.9000603@hp.com>
 <57C9024A16AD2D4C97DC78E552063EA35F317617@orsmsx505.amr.corp.intel.com>
 <alpine.DEB.1.10.0901281146260.13825@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>,
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
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0901281146260.13825@qirst.com>
Content-Language: en-US
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Managing a larger space could be done ... but at the expense of making
> > the Alt-DTLB miss handler do a memory lookup to find the physical address
> > of the per-cpu page needed (assuming that we allocate a bunch of random
> > physical pages for use as per-cpu space rather than a single contiguous
> > block of physical memory).
>
> We cannot resize the area by using a single larger TLB entry?

Yes we could ... the catch is that the supported TLB page sizes go
up by multiples of 4.  So if 64K is not enough the next stop is
at 256K, then 1M, then 4M, and so on.

That's why I asked when we know what total amount of per-cpu memory
is needed.  CONFIG time or boot time is good, because allocating higher
order pages is easy at boot time.  Arbitrary run time is bad because
we might have difficulty allocating a high order page for every cpu.

-Tony
