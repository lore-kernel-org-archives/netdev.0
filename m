From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Rework rx_work_todo
Date: Wed, 15 Jan 2014 14:59:51 +0000
Message-ID: <20140115145951.GP5698@zion.uk.xensource.com>
References: <1389727719-21439-1-git-send-email-zoltan.kiss@citrix.com>
 <20140115103707.GI5698@zion.uk.xensource.com>
 <52D67536.4030106@citrix.com>
 <20140115144519.GO5698@zion.uk.xensource.com>
 <52D6A0B9.2030204@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25828 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaAOO7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:59:53 -0500
Content-Disposition: inline
In-Reply-To: <52D6A0B9.2030204@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 02:52:41PM +0000, Zoltan Kiss wrote:
> On 15/01/14 14:45, Wei Liu wrote:
> >>>>The recent patch to fix receive side flow control (11b57f) solved the spinning
> >>>>> >>thread problem, however caused an another one. The receive side can stall, if:
> >>>>> >>- xenvif_rx_action sets rx_queue_stopped to false
> >>>>> >>- interrupt happens, and sets rx_event to true
> >>>>> >>- then xenvif_kthread sets rx_event to false
> >>>>> >>
> >>>> >
> >>>> >If you mean "rx_work_todo" returns false.
> >>>> >
> >>>> >In this case
> >>>> >
> >>>> >(!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) || vif->rx_event;
> >>>> >
> >>>> >can still be true, can't it?
> >>>Sorry, I should wrote rx_queue_stopped to true
> >>>
> >In this case, if rx_queue_stopped is true, then we're expecting frontend
> >to notify us, right?
> >
> >rx_queue_stopped is set to true if we cannot make any progress to queue
> >packet into the ring. In that situation we can expect frontend will send
> >notification to backend after it goes through the backlog in the ring.
> >That means rx_event is set to true, and rx_work_todo is true again. So
> >the ring is actually not stalled in this case as well. Did I miss
> >something?
> >
> 
> Yes, we expect the guest to notify us, and it does, and we set
> rx_event to true (see second point), but then the thread set it to
> false (see third point). Talking with Paul, another solution could
> be to set rx_event false before calling xenvif_rx_action. But using
> rx_last_skb_slots makes it quicker for the thread to see if it
> doesn't have to do anything.
> 

OK, this is a better explaination. So actually there's no bug in the
original implementation and your patch is sort of an improvement.

Could you send a new version of this patch with relevant information in
commit message? Talking to people offline is faster, but I would like to
have public discussion and relevant information archived in a searchable
form. Thanks.

Wei.

> Zoli
