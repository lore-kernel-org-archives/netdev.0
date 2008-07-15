From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH net-next? 1/1] netlabel: return msg overflow error from netlbl_cipsov4_list faster
Date: Tue, 15 Jul 2008 08:47:43 -0400
Message-ID: <200807150847.43895.paul.moore@hp.com>
References: <1215773149-27728-1-git-send-email-den@openvz.org> <200807110701.05377.paul.moore@hp.com> <20080714.222915.159608599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:8861 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757958AbYGOMrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 08:47:53 -0400
In-Reply-To: <20080714.222915.159608599.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 July 2008 1:29:15 am David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Fri, 11 Jul 2008 07:01:05 -0400
>
> > On Friday 11 July 2008 6:45:49 am Denis V. Lunev wrote:
> > > Currently, we are trying to place the information from the kernel
> > > to 1, 2, 3 and 4 pages sequentially. These pages are allocated
> > > via slab. Though, from the slab point of view steps 3 and 4 are
> > > equivalent on most architectures. So, lets skip 3 pages attempt.
> > >
> > > By the way, should we switch from .doit to .dumpit interface
> > > here? The amount of data seems quite big for me.
> > >
> > > Signed-off-by: Denis V. Lunev <den@openvz.org>
> >
> > I'll add my ack to this patch because your logic sounds reasonable
> > and I'm glad to have more eyes on the code :)
> >
> > However, I not a big fan of converting this from a .doit to a
> > .dumpit interface because this would cause userspace breakage.  We
> > could potentially do both for backwards compatibility but I have no
> > idea if it is possible to have both interfaces available at the
> > same time.  One thing to keep in mind before diving into your
> > favorite editor is that I've yet to hear of there being a problem
> > with this NetLabel command and the .doit interface, we may want to
> > hold off to see if it becomes an issue.
> >
> > Acked-by: Paul Moore <paul.moore@hp.com>
>
> I've applied Denis's patch.
>
> Also, I agree with him that a .dumpit conversion might be
> entirely appropriate.

After Dennis' mail I looked into a bit more and there doesn't appear to 
be any reason why you couldn't have both a .doit and a .dumpit 
interface for the same command.  I'll throw this on the ToDo list, but 
if anyone already has patches I'd be more than happy to review them ;)

-- 
paul moore
linux @ hp
