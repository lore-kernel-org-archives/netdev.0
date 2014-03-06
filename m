From: Dave Jones <davej@redhat.com>
Subject: Re: net: sctp: rework multihoming retransmission path selection to
 rfc4960
Date: Thu, 6 Mar 2014 01:02:32 -0500
Message-ID: <20140306060232.GA26578@redhat.com>
References: <20140305192635.6D9F7660D13@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, linux-coverity@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbaCFGCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 01:02:40 -0500
Content-Disposition: inline
In-Reply-To: <20140305192635.6D9F7660D13@gitolite.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 07:26:35PM +0000, Linux Kernel wrote:
 > Gitweb:     http://git.kernel.org/linus/;a=commit;h=4c47af4d5eb2c2f78f886079a3920a7078a6f0a0
 > Commit:     4c47af4d5eb2c2f78f886079a3920a7078a6f0a0
 > Parent:     b194c1f1dbd5f2671e49e0ac801b1b78dc7de93b
 > Author:     Daniel Borkmann <dborkman@redhat.com>
 > AuthorDate: Thu Feb 20 20:51:06 2014 +0100
 > Committer:  David S. Miller <davem@davemloft.net>
 > CommitDate: Sat Feb 22 00:26:05 2014 -0500
 > 
 >     net: sctp: rework multihoming retransmission path selection to rfc4960

minor nit that coverity just picked up..
 
 > +	/* Iterate from retran_path's successor back to retran_path. */
 > +	for (trans = list_next_entry(trans, transports); 1;
 > +	     trans = list_next_entry(trans, transports)) {
 > +		/* Manually skip the head element. */
 > +		if (&trans->transports == &asoc->peer.transport_addr_list)
 > +			continue;
 > +		if (trans->state == SCTP_UNCONFIRMED)
 > +			continue;
 > +		trans_next = sctp_trans_elect_best(trans, trans_next);
 > +		/* Active is good enough for immediate return. */
 > +		if (trans_next->state == SCTP_ACTIVE)
 >  			break;

^ trans_next dereference ...
 
 > +		/* We've reached the end, time to update path. */
 > +		if (trans == asoc->peer.retran_path)
 >  			break;
 >  	}
 >  
 > +	if (trans_next != NULL)
 > +		asoc->peer.retran_path = trans_next;

Belated NULL check.

Either the check is redundant, or it needs to be moved up.

	Dave
 
