From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 03/15] net: sched: cls_basic use RCU
Date: Tue, 09 Sep 2014 05:29:58 -0700
Message-ID: <1410265798.11872.155.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055507.2071.68285.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:46068 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177AbaIIM37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:29:59 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so4645591pab.18
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:29:59 -0700 (PDT)
In-Reply-To: <20140909055507.2071.68285.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:55 -0700, John Fastabend wrote:
> Enable basic classifier for RCU.
> 
> Dereferencing tp->root may look a bit strange here but it is needed
> by my accounting because it is allocated at init time and needs to
> be kfree'd at destroy time. However because it may be referenced in
> the classify() path we must wait an RCU grace period before free'ing
> it. We use kfree_rcu() and rcu_ APIs to enforce this. This pattern
> is used in all the classifiers.
> 
> Also the hgenerator can be incremented without concern because it
> is always incremented under RTNL.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
