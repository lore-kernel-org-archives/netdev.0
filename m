From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/7] NetLabel: CIPSOv4 engine
Date: Sat, 15 Jul 2006 11:09:29 -0400
Message-ID: <200607151109.30338.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185915.270209000@flek.zko.hp.com> <Pine.LNX.4.64.0607150905550.24495@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:9384 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1750700AbWGOPJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:09:41 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607150905550.24495@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 July 2006 9:08 am, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +struct sk_buff *cipso_v4_doi_dump_all(const size_t headroom)
> > +{
> > +	struct sk_buff *skb;
> > +	unsigned char *buf;
> > +	struct cipso_v4_doi *iter;
> > +	u32 doi_cnt = 0;
> > +	ssize_t buf_len;
> > +
> > +	/* XXX - In both cases, this is kinda ugly as we have to go through
> > +	   the list once to determine how large of a buffer we need,
> > +	   drop the locks, allocate the buffer, grab the locks, and
> > +	   finally fill the buffer.  The problem is that there is that
> > +	   open window where the table could grow and we will end up
> > +	   short on space. */
>
> This needs to be fixed.

The reasoning behind this was because I wanted to try and avoid holding the 
rcu_read_lock() while allocating memory.  I'll just change the allocation to 
GFP_ATOMIC and keep the rcu lock.

> Currently, it seems that you just bail if this happens.

-- 
paul moore
linux security @ hp
