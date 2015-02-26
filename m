From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next PATCH 4/4] fib_trie: Remove leaf_info
Date: Thu, 26 Feb 2015 02:06:16 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502260124420.27068@ja.home.ssi.bg>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190625.1747.49993.stgit@ahduyck-vm-fedora20> <alpine.LFD.2.11.1502252341500.2970@ja.home.ssi.bg> <54EE560E.8050504@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48899 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752883AbbBZAG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 19:06:28 -0500
In-Reply-To: <54EE560E.8050504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 25 Feb 2015, Alexander Duyck wrote:

> > 	If there is some fa in list with higher fa_slen
> > fib_find_alias will always stop the loop and come with
> > fa != NULL, so above 'if...break' is not needed, we are
> > always going to add at tail when fa is NULL.
> 
> Actually fib_find_alias will return NULL in the case that there was a hole in
> which the suffix length does not exist.
> 
> So for example if we have a suffix length of 8 and one of 10 and we are adding
> a suffix length of 9 then fib_find_alias will return NULL and we need to walk
> though the list and find the hole we are supposed to drop the suffix in.

	I missed the fact that we return NULL instead of fa.
I thought, it would be more consistent with the old logic
to return a stop position. And we avoid walking the list
again. But in practice we should not see many entries here,
right?

> Why are you showing me an example with a 32b int when I am using a long?  For
> x86 a 32b shift on a 32b value is undefined so we need to compare the suffix
> length to the KEYLENGTH.  For 64b a long value can be shifted up to 63 bits
> and still be a defined value.  That is why I use "1ul" as the value being
> shifted and then also perform the check for KEYLENGTH vs BITS_PER_LONG in
> order to determine if I still need the check for fa_slen != KEYLENGTH.

	I see, so, on 64-bit platform we avoid the
KEYLENGTH check... OK, that is better.

Regards

--
Julian Anastasov <ja@ssi.bg>
