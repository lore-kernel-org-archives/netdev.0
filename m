From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next PATCH 2/4] fib_trie: Replace plen with slen in
 leaf_info
Date: Thu, 26 Feb 2015 00:43:04 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502260038050.2970@ja.home.ssi.bg>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190610.1747.3307.stgit@ahduyck-vm-fedora20> <alpine.LFD.2.11.1502252158580.2970@ja.home.ssi.bg> <54EE3F04.2000703@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48560 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753011AbbBYWnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 17:43:37 -0500
In-Reply-To: <54EE3F04.2000703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 25 Feb 2015, Alexander Duyck wrote:

> > > +		if (((key ^ n->key) >> li->slen) &&
> > > +		    ((BITS_PER_LONG > KEYLENGTH) || (li->slen != KEYLENGTH)))
> > >      continue;
> > 	The '(BITS_PER_LONG > KEYLENGTH) ||' part is not
> > needed because on 64-bit processor we can still use
> > 32-bit register (due to 32-bit t_key type) and to get
> > undefined (!0) result from rshift with 32. We do not want
> > to continue in this case. Is it really working on 64-bit for
> > 0.0.0.0/0 ?
> 
> It is working but that may be due to the fact that gcc decided to place the
> key in a 64b register.
> 
> The last patch in the series probably does a better job of addressing your
> concern.  It replaces the shift with a comparison to (1ul << fa->fa_slen).  In
> that case I believe the BITS_PER_LONG check would then be appropriate would it
> not?

	I guess, it expands value to 64 bits due to the
"l" letter, try with "1U << fa->fa_slen" and BITS_PER_LONG
will not be needed. Or more correctly ((t_key)1 << fa->fa_slen).

Regards

--
Julian Anastasov <ja@ssi.bg>
