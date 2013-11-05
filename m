From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next v2 2/3] tipc: message reassembly using fragment
 chain
Date: Tue, 5 Nov 2013 09:15:26 +0100
Message-ID: <20131105081526.GA26341@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1383208814-23476-1-git-send-email-erik.hugne@ericsson.com>
 <1383208814-23476-3-git-send-email-erik.hugne@ericsson.com>
 <20131104.161254.1576011108092991976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <paul.gortmaker@windriver.com>,
	<ying.xue@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:48385 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab3KEIP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 03:15:29 -0500
Content-Disposition: inline
In-Reply-To: <20131104.161254.1576011108092991976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 04:12:54PM -0500, David Miller wrote:
> From: <erik.hugne@ericsson.com>
> Date: Thu, 31 Oct 2013 09:40:13 +0100
> 
> > +	skb_pull(frag, msg_hdr_sz(msg));
> > +	if (fragid == FIRST_FRAGMENT) {
> > +		if (*head)
> > +			goto out_free;
> > +		*head = frag;
> > +		skb_frag_list_init(*head);
> >  		return 0;
> > +	} else {
> > +		if (!*head)
> > +			goto out_free;
> > +		if (!skb_has_frag_list(*head))
> > +			skb_shinfo(*head)->frag_list = frag;
> > +		else
> > +			(*tail)->next = frag;
> > +		*tail = frag;
> > +		(*head)->truesize += frag->truesize;
> > +	}
> > +	if (fragid == LAST_FRAGMENT) {
> > +		*fbuf = *head;
> > +		*tail = *head = NULL;
> > +		return LINK_REASM_COMPLETE;
> >  	}
> 
> Please use skb_try_coalese(), and only use frag lists if that does not
> succeed.

Will fix.

> 
> Also you must be certain to unclone the SKB if you are going to modify
> it in this kind of way.

Is it enough to just unclone the list head skb?

> 
> For a good example of how to attend to all of these things, see
> ip_frag_reasm() in net/ipv4/ip_fragment.c

Thanks David.
