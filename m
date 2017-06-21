From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH rdma-next 11/19] RDMA/netlink: Convert LS to doit callback
Date: Wed, 21 Jun 2017 10:25:18 -0500
Message-ID: <033201d2eaa2$96e55860$c4b00920$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-12-leon@kernel.org> <022a01d2ea99$3eed7150$bcc853f0$@opengridcomputing.com> <20170621145354.GF1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Doug Ledford'" <dledford@redhat.com>,
        <linux-rdma@vger.kernel.org>,
        "'Chien Tin Tung'" <chien.tin.tung@intel.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        "'Jiri Pirko'" <jiri@mellanox.com>,
        "'Ariel Almog'" <ariela@mellanox.com>,
        "'Linux Netdev'" <netdev@vger.kernel.org>
To: "'Leon Romanovsky'" <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:53066 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752339AbdFUQpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:45:02 -0400
In-Reply-To: <20170621145354.GF1248@mtr-leonro.local>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > -	/*
> > > -	 * For response or local service set_timeout request,
> > > -	 * there is no need to use netlink_dump_start.
> > > -	 */
> > > -	if (!(nlh->nlmsg_flags & NLM_F_REQUEST) ||
> > > -	    (index == RDMA_NL_LS && op == RDMA_NL_LS_OP_SET_TIMEOUT)) {
> > > -		cb.skb = skb;
> > > -		cb.nlh = nlh;
> > > -		cb.dump = cb_table[op].dump;
> > > -		return cb.dump(skb, &cb);
> > > -	} else {
> > > -		c.dump = cb_table[op].dump;
> > > +	/* TODO: Convert IWCM to properly handle doit callbacks */
> > > +	if ((nlh->nlmsg_flags & NLM_F_DUMP) || index == RDMA_NL_RDMA_CM
> > > ||
> > > +	    index == RDMA_NL_IWCM) {
> > > +		struct netlink_dump_control c = {
> > > +			.dump = cb_table[op].dump,
> > > +		};
> >
> > Any reason you didn't fix IWCM as part of this series?  Or will you fix it
in an
> > upcoming series?  Also, isn't FIXME: the norm for these sorts of "I don't
want
> > to fix this now" comments?
> 
> I wanted to stop before it is growing into enormous series. There are
> number of things which I wanted to discuss and fix before moving forward.
> 
> 1. What should we do with exported RDMA-CM statistics and structures? I
> have a very strong feeling that it is broken and anyway, I'm not going to
> use it, because it doesn't follow netlink's TLV style.
> 
> 2. How to handle IWCM code which sets manually MSG_DONE and isn't using
> MULTI flag? It has very similar pattern to my "workarounds", when I didn't
> handle properly end of message.
> 
> 3. Need to remove nl_client from IWCM code.
> 

Chien, can you please comment on this? 

Thanks!

Steve.
