From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 19:26:43 -0400
Message-ID: <200607151926.44387.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607151837530.28012@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.22]:47196 "EHLO
	ccerelrim01.cce.hp.com") by vger.kernel.org with ESMTP
	id S1946000AbWGOX1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 19:27:11 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607151837530.28012@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 July 2006 6:39 pm, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +int cipso_v4_cache_add(const struct sk_buff *skb,
> > +		       const struct netlbl_lsm_secattr *secattr)
> > +{
>
> It seems that this cache grows without bounds, correct?

Unless I messed something up the cache is limited to  CIPSO_V4_CACHE_BUCKETS *  
cipso_v4_cache_bucketsize; see the bottom half of cipso_v4_cache_add() for 
details.

> Also, how do you handle the case of a change to a cached mapping?

Through the use of  cipso_v4_cache_invalidate() which gets called on CIPSO DOI 
deletes and SELinux policy [re]loads.  It's a bit heavy handed in that it 
clears the entire cache, but both events should be pretty rare in practice 
and the extra work to clear specific cache entries probably isn't worth it.

-- 
paul moore
linux security @ hp
