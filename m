From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next PATCH 2/4] fib_trie: Replace plen with slen in
 leaf_info
Date: Wed, 25 Feb 2015 23:15:06 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502252158580.2970@ja.home.ssi.bg>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190610.1747.3307.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48538 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753225AbbBYVPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 16:15:21 -0500
In-Reply-To: <20150225190610.1747.3307.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 25 Feb 2015, Alexander Duyck wrote:

>  	hlist_for_each_entry_rcu(li, &n->list, hlist) {
>  		struct fib_alias *fa;
>  
> -		if ((key ^ n->key) & li->mask_plen)
> +		if (((key ^ n->key) >> li->slen) &&
> +		    ((BITS_PER_LONG > KEYLENGTH) || (li->slen != KEYLENGTH)))
>  			continue;

	The '(BITS_PER_LONG > KEYLENGTH) ||' part is not
needed because on 64-bit processor we can still use
32-bit register (due to 32-bit t_key type) and to get
undefined (!0) result from rshift with 32. We do not want
to continue in this case. Is it really working on 64-bit for
0.0.0.0/0 ?

Regards

--
Julian Anastasov <ja@ssi.bg>
