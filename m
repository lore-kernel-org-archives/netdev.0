From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 21 Apr 2009 11:09:18 +0200
Message-ID: <20090421090918.GA6034@mail.wantstofly.org>
References: <20090130065721.GA4886@gondor.apana.org.au> <adaiqnwr91j.fsf@cisco.com> <20090130.135107.116108989.davem@davemloft.net> <ada3af0qgez.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	aluno3@poczta.onet.pl, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38517 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbZDUJJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 05:09:04 -0400
Content-Disposition: inline
In-Reply-To: <ada3af0qgez.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 07:54:12PM -0800, Roland Dreier wrote:

> > > I don't believe this is accurate.  Calling skb_linearize() (on a kernel
> > > with CONFIG_HIGHMEM set) can end up calling local_bh_enable() in
> > > kunmap_skb_frag(), which can obviously cause problems if the initial
> > > context relies on having BHs disabled (as hard_start_xmit does).
> >
> > local_bh_{enable,disable}() nests, so this is not a problem
> 
> Duh.  OK, then the only bugs seem to be that iw_nes does skb_linearize
> with irqs off (due to being an LLTX driver), and mv643xx_eth leaks an
> skb on its error path if skb_linearize fails.

(Found this when deleting old netdev@ mail...)  mv643xx_eth returns
NETDEV_TX_BUSY if skb_linearize fails, so the qdisc will requeue the
skb, and we shouldn't free it.  Am I missing something?
