From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:00:26 -0700 (PDT)
Message-ID: <20080910.160026.31554352.davem@davemloft.net>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	<20080910220115.GH20815@postel.suug.ch>
	<166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, akpm@linux-foundation.org, kaber@trash.net,
	lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ranjitm@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbYIJXAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:00:32 -0400
In-Reply-To: <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ranjit Manomohan" <ranjitm@google.com>
Date: Wed, 10 Sep 2008 15:56:55 -0700

> That is correct for ingress, for egress the sk is already available in
> the skb so should be fine.

That is not something you can rely upon, even for egress, %100 of the time.

Some forms of reallocation and mangling might decide to orphan the SKB
and thus drop the skb->sk reference before you see the packet.  And they
are absolutely free to do this.

Just grep for skb_orphan().

Therefore, it is absolutely something you should not rely upon for
correct operation.

Like I said from the beginning, Thomas's approach is the superior one.
