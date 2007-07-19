From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 17:21:05 +0100
Message-ID: <20070719172105.01454686@oldman.hamilton.local>
References: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47103 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762398AbXGSQVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:21:21 -0400
In-Reply-To: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 08:47:01 -0700 (PDT)
andrei radulescu-banu <iubica2@yahoo.com> wrote:

> The consensus seems to be that skb's need to carry vlan accelerated tags in their cb's, on rx as well as tx. VLAN_TX_SKB_CB() is perfect for that.
> 
> > [Patrick] On the TX path, it could simply use the CB, but this is actually
> also wrong (for both macvlan and real devices) since qdiscs have
> ownership of the skb in between, and at least netem *does* modify
> the CB, breaking VLAN.

No, VLAN is wrong to expect the CB to survive through layers. The CB is
a private scribble area that can be used by which ever piece of code currently
"owns" the skb.  If data needs to be passed from layer to layer, it needs to
be done as separate fields in the skb itself. If A passes an skb to B, then
the CB can be changed by B (or things it calls) before it arrives at C.



