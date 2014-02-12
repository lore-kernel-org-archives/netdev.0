From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: nf_tables: add reject module for NFPROTO_INET
Date: Wed, 12 Feb 2014 14:27:54 +0000
Message-ID: <20140212142754.GA303@macbook.localnet>
References: <20140211203359.56ED7660CD3@gitolite.kernel.org>
 <20140212141827.GA7129@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pablo@netfilter.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62958 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbaBLO17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:27:59 -0500
Content-Disposition: inline
In-Reply-To: <20140212141827.GA7129@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 09:18:27AM -0500, Dave Jones wrote:
> On Tue, Feb 11, 2014 at 08:33:59PM +0000, Linux Kernel wrote:
>  > Gitweb:     http://git.kernel.org/linus/;a=commit;h=05513e9e33dbded8124567466a444d32173eecc6
>  > Commit:     05513e9e33dbded8124567466a444d32173eecc6
>  > Parent:     cc4723ca316742891954efa346298e7c747c0d17
>  > Author:     Patrick McHardy <kaber@trash.net>
>  > AuthorDate: Wed Feb 5 15:03:39 2014 +0000
>  > Committer:  Pablo Neira Ayuso <pablo@netfilter.org>
>  > CommitDate: Thu Feb 6 09:44:18 2014 +0100
>  > 
>  >     netfilter: nf_tables: add reject module for NFPROTO_INET
>  >     
>  >     Add a reject module for NFPROTO_INET. It does nothing but dispatch
>  >     to the AF-specific modules based on the hook family.
>  >     
>  >     Signed-off-by: Patrick McHardy <kaber@trash.net>
>  >     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>  > ---
> 
> ....
> 
>  > +static void nft_reject_inet_eval(const struct nft_expr *expr,
>  > +				 struct nft_data data[NFT_REG_MAX + 1],
>  > +				 const struct nft_pktinfo *pkt)
>  > +{
>  > +	switch (pkt->ops->pf) {
>  > +	case NFPROTO_IPV4:
>  > +		nft_reject_ipv4_eval(expr, data, pkt);
>  > +	case NFPROTO_IPV6:
>  > +		nft_reject_ipv6_eval(expr, data, pkt);
>  > +	}
>  > +}
> 
> Is the fallthrough intentional here, or is there a missing break ?

Crap. Thanks for catching this, I'll send a fix later.
