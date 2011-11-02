From: Anton Blanchard <anton@samba.org>
Subject: Re: ARP garbage collection issues in 3.1?
Date: Wed, 2 Nov 2011 21:07:31 +1100
Message-ID: <20111102210731.281c3277@kryten>
References: <20111102153443.38cc1e5c@kryten>
	<20111102.004820.1600243559959513379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:34992 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab1KBKHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 06:07:33 -0400
In-Reply-To: <20111102.004820.1600243559959513379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

> > Any ideas how we could make this behave a bit better? I know setting
> > gc_thresh3 higher is the ultimate solution, but if gc_thresh1 and
> > gc_thresh2 are always below the route threshold we should either fix
> > this issue or remove them completely.
> 
> The solution is to do refcount'less RCU lookups into the neigh
> tables on every packet send, and long term that's what I intend
> to implement.
> 
> That's what's behind making the recent change to make the ARP hash
> cheaper etc.
> 
> See slides 5, 6, and 7 in:
> 
> http://vger.kernel.org/netconf2011_slides/davem_netconf2011.pdf
> 
> Once that's done you can trim whatever neigh entries you want,
> whenever you want.
> 
> You are right that the current situation is silly, because if
> we're willing to commit to N routing table entries we might as
> well be willing to commit to N arp table entries as well.

Thanks for clearing it up! Looking forwards to the new scheme :)

Anton
