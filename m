From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 1/5] vringfd syscall
Date: Sun, 13 Apr 2008 04:19:54 +1000
Message-ID: <200804130419.55083.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <20080412171820.GA29568@dmt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41004 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755387AbYDLSUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 14:20:03 -0400
In-Reply-To: <20080412171820.GA29568@dmt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 13 April 2008 03:18:20 Marcelo Tosatti wrote:
> I suppose you are doing data copy in ->poll instead of ->read to save
> a system call? This is weird, not conformant to what the interface is
> supposed to do.

Hi Marcelo,

   Thanks for reading this.

   Yeah, I dislike it too.  The main motivation was that not all rings need to 
be "pulled" in this way, but it turns out that userspace can detect this 
(poll, check ring, if nothing, try read, check ring).  So next version will 
unscrew the poll callback.

> > +	/* If they want to use atomically, we have to map the page. */
> > +	if (atomic_use) {
> > +		if (get_user_pages(current, current->mm,
> > +				   (unsigned long)vr->ring.used, 1, 1, 1,
> > +				   &vr->used_page, NULL) != 1) {
>
> Can't the same be achieved by the app mlocking the vring pages, which
> then goes through standard rlimit checking ?

Tun/tap writes to this from any context.  Fortunately, this too is changing, 
as I came up with a sane way of queueing to userspace context for this case.

Expect updated patches Monday.

Thanks!
Rusty.
