From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Date: Fri, 25 Jul 2008 11:25:58 +0100
Message-ID: <20080725102558.GB21357@gerrit.erg.abdn.ac.uk>
References: <1216976578-17767-4-git-send-email-gerrit@erg.abdn.ac.uk> <1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk> <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk> <20080725.025145.51942248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org, yjwei@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57570 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566AbYGYK0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 06:26:19 -0400
Content-Disposition: inline
In-Reply-To: <20080725.025145.51942248.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > -	if (skb->len < (iph->ihl << 2) + 8) {
| > +	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
| >  		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
| >  		return;
| >  	}
| 
| You can't dereference "dh" before you know there is even
| space past offset "iph->ihl << 2".  Yet that is what doing
| an unconditional __dccp_basic_hdr_len() call here is going
| to do.
| 
Oh that was my fault. Thanks a lot for pointing this out.

Will work out a fixed/improved version for both patches,
test and then resubmit.

Gerrit
