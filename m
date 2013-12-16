From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 8/9] xen-netback: Timeout packets in RX path
Date: Mon, 16 Dec 2013 19:03:06 +0000
Message-ID: <20131216190306.GE25969@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-9-git-send-email-zoltan.kiss@citrix.com>
 <20131213154406.GO21900@zion.uk.xensource.com>
 <52AF3561.9020904@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52AF3561.9020904@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 05:16:17PM +0000, Zoltan Kiss wrote:
> On 13/12/13 15:44, Wei Liu wrote:
> >On Thu, Dec 12, 2013 at 11:48:16PM +0000, Zoltan Kiss wrote:
> >>A malicious or buggy guest can leave its queue filled indefinitely, in which
> >>case qdisc start to queue packets for that VIF. If those packets came from an
> >>another guest, it can block its slots and prevent shutdown. To avoid that, we
> >>make sure the queue is drained in every 10 seconds
> >>
> >
> >Oh I see where the 10 second constraint in previous patch comes from.
> >
> >Could you define a macro for this constant then use it everywhere.
> Well, they are not entirely the same thing, but worth making them
> the same. How about using "unmap_timeout >
> (rx_drain_timeout_msecs/1000)" in xenvif_free()? Then netback won't
> complain about a stucked page if an another guest is permitted to
> hold on to it.
> 

Thanks for clarification. I see the difference. If they are not the same
by definition then we need to think more about making them the same in
practice.

If we use  "unmap_timeout > (rx_drain_timeout_msecs/1000)" then we
basically assume that guest RX path is the one who is most likely to
hold the packet for the longest time.

Wei.
