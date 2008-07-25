From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 30/30] nfs: fix various memory recursions possible with
	swap over NFS.
Date: Fri, 25 Jul 2008 13:19:01 +0200
Message-ID: <1216984741.7257.366.camel@twins>
References: <20080725194517.86BB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1216983472.7257.365.camel@twins>
	 <20080725201324.86BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:61604 "EHLO
	viefep15-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751942AbYGYLTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 07:19:00 -0400
Received: from edge01.upc.biz ([192.168.13.236]) by viefep15-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080725111854.WEHG14014.viefep15-int.chello.at@edge01.upc.biz>
          for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 13:18:54 +0200
In-Reply-To: <20080725201324.86BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-25 at 20:15 +0900, KOSAKI Motohiro wrote:
> > On Fri, 2008-07-25 at 19:46 +0900, KOSAKI Motohiro wrote:
> > > > GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.
> > > 
> > > this comment imply turn on GFP_NOIO, but the code is s/NOFS/NOIO/. why?
> > 
> > Does the misunderstanding stem from the use of 'enough'?
> > 
> > GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate IO,
> > just not of any filesystem data.
> > 
> 
> 
> > The problem is that previuosly NOFS was correct because that avoids
> > recursion into the NFS code, it now is not, because also IO (swap) can
> > lead to this recursion.
> 
> 
> Thanks nicer explain.
> So, I hope add above 3 line to patch description.

Done, thanks!

