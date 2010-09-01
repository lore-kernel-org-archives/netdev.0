From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 17:18:56 +0200
Message-ID: <20100901151856.GB3091@del.dom.local>
References: <20136.1283288063@death>
 <20100901122356.GB9468@ff.dom.local>
 <20100901133056.GB12447@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, markine@google.com,
	chavey@google.com, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55817 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab0IAPTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 11:19:02 -0400
Received: by eyb6 with SMTP id 6so594369eyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 08:19:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100901133056.GB12447@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 03:30:56PM +0200, Jiri Bohac wrote:
> On Wed, Sep 01, 2010 at 12:23:56PM +0000, Jarek Poplawski wrote:
> > On 2010-08-31 22:54, Jay Vosburgh wrote:
> > > 	What prevents this from deadlocking such that cpu A is in
> > > bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
> > > in the above function, trying to acquire RTNL?
> > 
> > I guess this one isn't cancelled in bond_close, so it should be safe.
> 
> Nah, Jay was correct. Although this work item is not explicitly
> cancelled with cancel_delayed_work_sync(), it is on the same
> workqueue as work items that are being cancelled with
> cancel_delayed_work_sync(), so this can still cause a deadlock.
> Fixed in the new version of the patch by putting these on a
> separate workqueue.
> 

Maybe I miss something, but the same workqueue shouldn't matter here.
Similar things are done by other network code with the kernel-global
workqueue.

Jarek P.
