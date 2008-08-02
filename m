From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 2 Aug 2008 22:19:44 +0200
Message-ID: <20080802201944.GA14983@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com> <20080802133719.GB2970@ami.dom.local> <20080802162733.GA10059@ami.dom.local> <20080802.121815.167998262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:2352 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448AbYHBUPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 16:15:15 -0400
Received: by nf-out-0910.google.com with SMTP id d3so573246nfc.21
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2008 13:15:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080802.121815.167998262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 02, 2008 at 12:18:15PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 2 Aug 2008 18:27:33 +0200
> 
> > On Sat, Aug 02, 2008 at 03:37:19PM +0200, Jarek Poplawski wrote:
> > ...
> > > I guess this "root lock" has to go back to netdev_queue. Alas, I can't
> > > test this, so if it's not a big problem maybe you could try this patch
> > > before David goes back to this? (His patch should be removed before
> > > using this one.)
> > 
> > Actually, this patch was incomplete, sorry. Here is a better one,
> > I hope. But of course, now, even better is to wait for David's
> > proposal.
> 
> Jarek, we can't put the root lock back into the netdev_queue, it
> breaks all of the RCU handling of qdisc_destroy() which is fundamental
> for how all the multiqueue stuff works now.
> 
> See my other emails, it isn't even necessary anyways.

My patch was intended to check this "the hard way" since the subtle
method didn't work. I expected the final fix could be different.

Thanks for the explanations: BTW, I think, the qdisc_root_lock is a
bit misleading name, if qdisc_lock is also used for taking root lock.
Of course, this all makes sense, it simply needs more checking.

Jarek P.
