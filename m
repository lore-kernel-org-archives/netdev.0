From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 4/5] tun: vringfd xmit support.
Date: Mon, 07 Apr 2008 00:35:28 -0700 (PDT)
Message-ID: <20080407.003528.96136816.davem@davemloft.net>
References: <E1Jijfs-0004Lo-00@gondolin.me.apana.org.au>
	<200804071724.51781.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	maxk@qualcomm.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751493AbYDGHf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 03:35:29 -0400
In-Reply-To: <200804071724.51781.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 7 Apr 2008 17:24:51 +1000

> On Monday 07 April 2008 15:13:44 Herbert Xu wrote:
> > On second thought, this is not going to work.  The network stack
> > can clone individual pages out of this skb and put it into a new
> > skb.  Therefore whatever scheme we come up with will either need
> > to be page-based, or add a flag to tell the network stack that it
> > can't clone those pages.
> 
> Erk... I'll put in the latter for now.   A page-level solution is not really 
> an option: if userspace hands us mmaped pages for example.

Keep in mind that the core of the TCP stack really depends
upon being able to slice and dice paged SKBs as is pleases
in order to send packets out.

In fact, it also does such splitting during SACK processing.

It really is a base requirement for efficient TSO support.
Otherwise the above operations would be so incredibly
expensive we might as well rip all of the TSO support out.
