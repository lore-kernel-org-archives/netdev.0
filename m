From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 13 Nov 2009 18:45:03 -0800
Message-ID: <20091113184503.13f6d447@s6510>
References: <20091002141407.30224.54207.stgit@dev.haskins.net>
	<20091110115335.GC6989@redhat.com>
	<4AF919020200005A000586A9@sinclair.provo.novell.com>
	<20091110131722.GA19645@redhat.com>
	<4AF9747E.8020408@novell.com>
	<20091110143652.GB19645@redhat.com>
	<4AF98A8C.9040201@novell.com>
	<20091114011229.GA18580@gondor.apana.org.au>
	<4AFE08EF.2030308@gmail.com>
	<20091114022103.GA19020@gondor.apana.org.au>
	<4AFE15AD.6000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36956 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986AbZKNCpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 21:45:30 -0500
In-Reply-To: <4AFE15AD.6000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 21:27:57 -0500
Gregory Haskins <gregory.haskins@gmail.com> wrote:

> Herbert Xu wrote:
> > On Fri, Nov 13, 2009 at 08:33:35PM -0500, Gregory Haskins wrote:
> >> Well, not with respect to the overall protocol, of course not.  But with
> >> respect to the buffer in question, it _has_ to be.  Or am I missing
> >> something?
> > 
> > sendfile() has never guaranteed that the kernel is finished with
> > the underlying pages when it returns.
> > 
> > Cheers,
> 
> Clearly there must be _some_ mechanism to synchronize (e.g.
> flush/barrier) though, right?  Otherwise, that interface would seem to
> be quite prone to races and would likely be unusable.   So what does
> said flush use to know when the buffer is free?

No all the interfaces require a copy. Actually, sendfile makes no guarantee about synchronization
because the receiver of said file could be arbitrarily slow, and any attempt at locking down
current contents of file is a denial of service exposure.

People have tried doing copy-less send by page flipping, but the overhead of the IPI to
invalidate the TLB exceeded the overhead of the copy. There was an Intel paper on this in
at Linux Symposium (Ottawa) several years ago.
