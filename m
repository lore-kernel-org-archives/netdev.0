From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Mon, 24 May 2010 21:58:51 -0700 (PDT)
Message-ID: <20100524.215851.207470612.davem@davemloft.net>
References: <20100525141046.975afe1f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45068
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310Ab0EYE6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 00:58:43 -0400
In-Reply-To: <20100525141046.975afe1f.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 25 May 2010 14:10:46 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> In file included from net/socket.c:97:
> include/net/cls_cgroup.h: In function 'task_cls_classid':
> include/net/cls_cgroup.h:33: error: request for member 'classid' in something not a structure or union
> In file included from net/core/sock.c:126:
> include/net/cls_cgroup.h: In function 'task_cls_classid':
> include/net/cls_cgroup.h:33: error: request for member 'classid' in something not a structure or union
> In file included from net/sched/cls_cgroup.c:23:
> include/net/cls_cgroup.h: In function 'task_cls_classid':
> include/net/cls_cgroup.h:33: error: request for member 'classid' in something not a structure or union
> 
> CONFIG_CGROUPS=y, CONFIG_NET_CLS_CGROUP=y
> 
> Caused by commit f845172531fb7410c7fb7780b1a6e51ee6df7d52 ("cls_cgroup:
> Store classid in struct sock") from the net-current tree.
> 
> I have reverted that commit for today (and commit
> 8286274284e15b11b0f531b6ceeef21fbe00a8dd "tun: Update classid on packet
> injection" that depends on it).

Yuck, and we already went through two iterations of this patch fixing exactly
these kinds of build problems :-/

Herbert, can you take a look?

Thanks!
