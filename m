From: Toerless Eckert <tte@cs.fau.de>
Subject: Re: vnet problem (bug? feature?)
Date: Mon, 16 Feb 2015 11:13:10 +0100
Message-ID: <20150216101309.GB25792@faui40p.informatik.uni-erlangen.de>
References: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
 <CAHA+R7NUojPsLY9LOC94S0uussbwKsGRdcbazNmGGLbXvxCk-A@mail.gmail.com>
 <20150214101547.GA9335@faui40p.informatik.uni-erlangen.de>
 <20150214131744.051b90fc8dfdbf4e1bfe6bfb@mindspring.com>
 <20150215190008.GA25792@faui40p.informatik.uni-erlangen.de>
 <CACP96tRBPy4cakmJY_K9zrYbgWLgNfxDo4inrH8qV6pgRtR-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:60429 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932078AbbBPKNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 05:13:12 -0500
Content-Disposition: inline
In-Reply-To: <CACP96tRBPy4cakmJY_K9zrYbgWLgNfxDo4inrH8qV6pgRtR-1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2015 at 04:16:21PM -0500, Sowmini Varadhan wrote:
> RPF !=  strong/weak ES models defined in Section 3.3.4.2 of rfc1122.

Agreed on the RFC definition, but not on the model. RP filtering makes
it more difficult, if not impossible to a weak-host. Consider the multi-homed
host that's attached such that it would receive packets for one of its addresses
from different interfaces. RP filtering throws away those packet from all but
one interface (just talking unicast hee for the sake of the argument).

> RPF is about ingress filtering (rfc 3704) and verifying that the return
> path to the src addr of the packet would go out on the same interface
> it came on. The wiki page on Reverse_path_forwarding has some detail.

rfc3704 does mention multicast only on the side, so i would claim Fred did
primarily think about unicast, and the whole text is also targeted for ISPs
== routers, not for RPF filtering on actual multi homed hosts.

Of course, RPF filtering for multicast has been traditionally used in
almost all relevant routing protocols, but again: thats only on routers,
and AFAIK in the distant past not on MHH.

I fail to find a good reference explaining why linux would default to
rp_filtering = 1 (more appropriate for routers) even if forwarding defaults to 0
(more appropriate for multi-homed hosts). 

Any ideas how to track back where this  choice came from ? 

Thanks!
    Toerless

> --Sowmini
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
---
Toerless.Eckert@informatik.uni-erlangen.de
/C=de/A=d400/P=uni-erlangen/OU=informatik/S=Eckert/G=Toerless/
