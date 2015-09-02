From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 2 Sep 2015 14:52:03 -0700
Message-ID: <20150902215203.GB78846@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150902205802.GA78846@kafai-mba.local>
 <1441229445.8932.206.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58428 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753182AbbIBVwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 17:52:10 -0400
Content-Disposition: inline
In-Reply-To: <1441229445.8932.206.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 02:30:45PM -0700, Eric Dumazet wrote:
> Object cannot be freed until all cpus have exited their RCU sections.
You meant the dst_destroy() here will wait for all cpus exited their RCU sections?

static inline void dst_free(struct dst_entry *dst)
{
	if (dst->obsolete > 0)
		return;
	if (!atomic_read(&dst->__refcnt)) {
		dst = dst_destroy(dst);
		if (!dst)
			return;
	}
	__dst_free(dst);
}
