From: Christoph Lameter <cl@linux-foundation.org>
Subject: RE: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 11:48:27 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901281146260.13825@qirst.com>
References: <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <alpine.DEB.1.10.0901271506580.3114@qirst.com> <20090127.134747.153565246.davem@davemloft.net> <497F8F02.9000603@hp.com>
 <57C9024A16AD2D4C97DC78E552063EA35F317617@orsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
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
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:46640 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752335AbZA1R5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 12:57:52 -0500
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35F317617@orsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2009, Luck, Tony wrote:

> Managing a larger space could be done ... but at the expense of making
> the Alt-DTLB miss handler do a memory lookup to find the physical address
> of the per-cpu page needed (assuming that we allocate a bunch of random
> physical pages for use as per-cpu space rather than a single contiguous
> block of physical memory).

We cannot resize the area by using a single larger TLB entry?

> When do we know the total amount of per-cpu memory needed?
> 1) CONFIG time?

Would be easiest.

> 2) Boot time?

We could make the TLB entry size configurable with a kernel parameter

> 3) Arbitrary run time?

We could reserve a larger virtual space and switch TLB entries as needed?
We would need do get larger order pages to do this.

