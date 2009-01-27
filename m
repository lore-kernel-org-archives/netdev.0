From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 27 Jan 2009 13:47:47 -0800 (PST)
Message-ID: <20090127.134747.153565246.davem@davemloft.net>
References: <200901271213.18605.rusty@rustcorp.com.au>
	<497E705B.5000302@kernel.org>
	<alpine.DEB.1.10.0901271506580.3114@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, rusty@rustcorp.com.au, mingo@elte.hu,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	hpa@zytor.com, brgerst@gmail.com, ebiederm@xmission.com,
	travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com,
	hugh@veritas.com, netdev@vger.kernel.org,
	mathieu.desnoyers@polymtl.ca
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50540
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754920AbZA0Vru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 16:47:50 -0500
In-Reply-To: <alpine.DEB.1.10.0901271506580.3114@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 27 Jan 2009 15:08:57 -0500 (EST)

> On Tue, 27 Jan 2009, Tejun Heo wrote:
> 
> > > later). That's because they use TLB tricks for a static 64k per-cpu
> > > area, but this doesn't scale.  That might not be vital: abandoning
> > > that trick will mean they can't optimise read_percpu/read_percpu_var
> > > etc as much.
> 
> Why wont it scale? this is a separate TLB entry for each processor.

The IA64 per-cpu TLB entry only covers 64k which makes use of it for
dynamic per-cpu stuff out of the question.  That's why it "doesn't
scale"
