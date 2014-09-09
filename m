From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 04/15] net: sched: cls_cgroup use RCU
Date: Tue, 09 Sep 2014 05:34:36 -0700
Message-ID: <1410266076.11872.156.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055534.2071.64610.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:52731 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbaIIMeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:34:37 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so8865805pdj.6
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:34:37 -0700 (PDT)
In-Reply-To: <20140909055534.2071.64610.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:55 -0700, John Fastabend wrote:
> Make cgroup classifier safe for RCU.
> 
> Also drops the calls in the classify routine that were doing a
> rcu_read_lock()/rcu_read_unlock(). If the rcu_read_lock() isn't held
> entering this routine we have issues with deleting the classifier
> chain so remove the unnecessary rcu_read_lock()/rcu_read_unlock()
> pair noting all paths AFAIK hold rcu_read_lock.
> 
> If there is a case where classify is called without the rcu read lock
> then an rcu splat will occur and we can correct it.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Eric Dumazet <edumazet@google.com>
