From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Sat, 25 Oct 2014 01:36:45 +0100
Message-ID: <20141025003644.GB11289@acer.localdomain>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
 <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
 <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Terry Lam <vtlam@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42957 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:36:50 -0400
Content-Disposition: inline
In-Reply-To: <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 05:14:13PM -0700, Eric Dumazet wrote:
> On Fri, 2014-10-24 at 16:55 -0700, Cong Wang wrote:
> > In qdisc_create(), when ->init() exists and it fails, we should
> > call ->destroy() to clean up the potentially partially initialized
> > qdisc's. This will also make the ->init() implementation easier.
> > 
> 
> Why is this patch needed ?
> 
> You are adding bugs, its not clear what bug you are fixing.
> 
> I really do not like the idea of ->init() relying on a ->destroy() to
> cleanup a failed ->init().
> 
> This is not what most management functions do in our stack.
> 
> I very much prefer that a function returning an error has no side
> effect, like if it hadnt be called at all.

Absolutely.

Again, the correct fix is to make qdisc_create_dflt() not call
qdisc_destroy() but clean up the qdisc manually as done in
qdisc_create().
