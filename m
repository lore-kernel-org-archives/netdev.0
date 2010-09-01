From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 21:38:59 +0200
Message-ID: <20100901193859.GB3151@del.dom.local>
References: <20136.1283288063@death>
 <20100901122356.GB9468@ff.dom.local>
 <20100901133056.GB12447@midget.suse.cz>
 <20100901151856.GB3091@del.dom.local>
 <20100901153730.GC3091@del.dom.local>
 <20100901190037.GA3030@del.dom.local>
 <20100901191106.GB25227@midget.suse.cz>
 <20100901192026.GA3151@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, markine@google.com,
	chavey@google.com, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55086 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755260Ab0IATjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 15:39:08 -0400
Received: by wwj40 with SMTP id 40so402480wwj.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 12:39:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100901192026.GA3151@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 09:20:26PM +0200, Jarek Poplawski wrote:
> On Wed, Sep 01, 2010 at 09:11:06PM +0200, Jiri Bohac wrote:
> > On Wed, Sep 01, 2010 at 09:00:37PM +0200, Jarek Poplawski wrote:
...
> > > Hmm#2... Alas, after getting back my sobriety, I've to say that Jay
> > > was wrong: the same workqueue shouldn't matter here. Similar things
> > > are done by other network code with the kernel-global workqueue, eg.
> > > in tg3_close(), rhine_close() etc. 
> > 
> > But these don't do rtnl_lock() inside the work item, do they?
> 
> Exactly. Just like work items cancelled from bond_work_cancel_all()
> after your patch.

IOW: cancel_delayed_work_sync() cares only about the locking of the
cancelled work item - not others, even in the same workqueue. Btw,
testing it with CONFIG_PROVE_LOCKING should give the last answer...

Jarek P.
