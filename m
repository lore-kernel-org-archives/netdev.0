From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 22:06:07 +0200
Message-ID: <20100901200607.GA3204@del.dom.local>
References: <20136.1283288063@death>
 <20100901122356.GB9468@ff.dom.local>
 <20100901133056.GB12447@midget.suse.cz>
 <20100901151856.GB3091@del.dom.local>
 <20100901153730.GC3091@del.dom.local>
 <20100901190037.GA3030@del.dom.local>
 <20100901191106.GB25227@midget.suse.cz>
 <20100901192026.GA3151@del.dom.local>
 <10270.1283370390@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, chavey@google.com, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50255 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694Ab0IAUGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:06:15 -0400
Received: by wwb13 with SMTP id 13so242859wwb.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 13:06:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <10270.1283370390@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 12:46:30PM -0700, Jay Vosburgh wrote:
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> >On Wed, Sep 01, 2010 at 09:11:06PM +0200, Jiri Bohac wrote:
> >> But these don't do rtnl_lock() inside the work item, do they?
> >
> >Exactly. Just like work items cancelled from bond_work_cancel_all()
> >after your patch.
> 
> 	I see what Jarek is getting at here: the mii_commit, etc, work
> items new to the patch aren't cancelled by bond_close, so bond_close (in
> cancel_delayed_work_sync) shouldn't care if they're executing or not.
> 
> 	This still would leave the new work items (the "commit" ones
> added in the patch) always free to run at some arbitrary time after
> close, which makes me uneasy.  I don't think the extra "wq_rtnl" makes
> any difference, though.

Sure, but IIRC it wasn't encouraged. After all, many net drivers do it
similarly and don't even need their separate workqueue.

Jarek P.
