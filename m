From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 02 Sep 2015 15:48:57 -0700
Message-ID: <1441234137.8932.209.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
	 <1441133703-1570969-4-git-send-email-kafai@fb.com>
	 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150902205802.GA78846@kafai-mba.local>
	 <1441229445.8932.206.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150902215203.GB78846@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33258 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbbIBWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:49:03 -0400
Received: by pacex6 with SMTP id ex6so19971680pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 15:49:02 -0700 (PDT)
In-Reply-To: <20150902215203.GB78846@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-02 at 14:52 -0700, Martin KaFai Lau wrote:
> On Wed, Sep 02, 2015 at 02:30:45PM -0700, Eric Dumazet wrote:
> > Object cannot be freed until all cpus have exited their RCU sections.
> You meant the dst_destroy() here will wait for all cpus exited their RCU sections?
> 
> static inline void dst_free(struct dst_entry *dst)
> {
> 	if (dst->obsolete > 0)
> 		return;
> 	if (!atomic_read(&dst->__refcnt)) {
> 		dst = dst_destroy(dst);
> 		if (!dst)
> 			return;
> 	}
> 	__dst_free(dst);
> }

dst_free() is called after RCU grace period, in the case you are
interested in.

Look at dst_rcu_free() and rt_free()
