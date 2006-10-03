From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Tue, 3 Oct 2006 12:28:32 +0200
Message-ID: <20061003102831.GA7778@kernel.dk>
References: <200609302223.47627.ismail@pardus.org.tr> <20061002102447.GA2936@ff.dom.local> <20061002111555.GB2936@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([62.242.22.158]:23156 "EHLO kernel.dk")
	by vger.kernel.org with ESMTP id S964833AbWJCK3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 06:29:00 -0400
To: Jarek Poplawski <jarkao2@o2.pl>,
	Ismail Donmez <ismail@pardus.org.tr>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061002111555.GB2936@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02 2006, Jarek Poplawski wrote:
> On Mon, Oct 02, 2006 at 12:24:47PM +0200, Jarek Poplawski wrote:
> > On 30-09-2006 21:23, Ismail Donmez wrote:
> > > Hi,
> > > 
> > > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
> > > changed behaviour so it returns false when the node is empty as expected. 
> > ...
> > > -	if (!RB_EMPTY_NODE(rb)) {
> > > +	if (RB_EMPTY_NODE(rb)) {
> > 
> > Maybe you have some kind of agreement with Jens Axboe but I
> > can't understand current way of kernel cooperation:
> > he changes some global behavior to the opposite and fixes
> > his code in three places but can't fix it in the fourth place
> ...
> 
> But I see it's not so bad and net_sched isn't the last!
> It looks deadline-iosched.c and one place in as-iosched.c
> (~ 466 line) where probably also forgotten. 

I don't see any missed changes.

> Another question - is there any change planned?
> If not why in rbtree.c is:
> 
> + if (rb_parent(node) == node)
> 
> instead of:
> 
> + if (RB_EMPTY_NODE(rb))

RB_EMPTY_NODE was (re)-introduced after that change, and it never
propagated. Changing it now would be fine and easier to read.

-- 
Jens Axboe

