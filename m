From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5] net: Add batman-adv meshing protocol
Date: Fri, 24 Sep 2010 13:43:34 -0700 (PDT)
Message-ID: <20100924.134334.28812338.davem@davemloft.net>
References: <1284836610-26799-1-git-send-email-sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sven.eckelmann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39950
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752884Ab0IXUnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 16:43:15 -0400
In-Reply-To: <1284836610-26799-1-git-send-email-sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@gmx.de>
Date: Sat, 18 Sep 2010 21:03:30 +0200

> B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
> protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
> wireless. See http://www.open-mesh.org/ for more information and user space
> tools.
> 
> Signed-off-by: Sven Eckelmann <sven.eckelmann@gmx.de>

The only thing remaining which I really don't like is this hash helper
library thing in here.

It's a terrible abstraction and very inefficient.  Iteration uses
function calls, as does removal.  Key comparisons use callbacks, via
indirection function pointers, also very inefficient.

Just use the "struct hlist_head" and "struct hlist_node" objects we
have generically already.  Inline the list iteration, as well as the
key comparisons and the node linking/unlinking.

Otherwise if you think your hash helpers are so incredibly useful,
propose for their inclusion under lib/ on linux-kernel

But frankly, I wish you a lot of luck with that. :-)
