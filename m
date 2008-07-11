From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next? 1/1] netlabel: return msg overflow error from
	netlbl_cipsov4_list faster
Date: Fri, 11 Jul 2008 16:13:12 +0400
Message-ID: <1215778392.7001.25.camel@iris.sw.ru>
References: <1215773149-27728-1-git-send-email-den@openvz.org>
	 <200807110701.05377.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44727 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994AbYGKMMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 08:12:36 -0400
In-Reply-To: <200807110701.05377.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-11 at 07:01 -0400, Paul Moore wrote:
> On Friday 11 July 2008 6:45:49 am Denis V. Lunev wrote:
> > Currently, we are trying to place the information from the kernel to
> > 1, 2, 3 and 4 pages sequentially. These pages are allocated via slab.
> > Though, from the slab point of view steps 3 and 4 are equivalent on
> > most architectures. So, lets skip 3 pages attempt.
> >
> > By the way, should we switch from .doit to .dumpit interface here?
> > The amount of data seems quite big for me.
> >
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> I'll add my ack to this patch because your logic sounds reasonable and 
> I'm glad to have more eyes on the code :)
cool :)

> However, I not a big fan of converting this from a .doit to a .dumpit 
> interface because this would cause userspace breakage.  We could 
> potentially do both for backwards compatibility but I have no idea if 
> it is possible to have both interfaces available at the same time.  One 
> thing to keep in mind before diving into your favorite editor is that 
> I've yet to hear of there being a problem with this NetLabel command 
> and the .doit interface, we may want to hold off to see if it becomes 
> an issue.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

for the dumpip interface. 2-order page is a real pain on the heavy
loaded systems. Yes, the allocation will not fail, but it can take a
significant amount of time to perform the allocation.

I understand your logic with keeping this interface, but such allocation
can take > 1 sec for sure.

