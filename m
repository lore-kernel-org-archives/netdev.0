From: "Eric Barton" <eeb@bartonsoftware.com>
Subject: RE: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 13:23:10 +0100
Message-ID: <020d01c6f1e7$029beb70$0281a8c0@ebpc>
References: <200610171101.38690.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.blueyonder.co.uk ([195.188.213.5]:22996 "EHLO
	smtp-out2.blueyonder.co.uk") by vger.kernel.org with ESMTP
	id S1750780AbWJQMXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 08:23:06 -0400
To: "'Eric Dumazet'" <dada1@cosmosbay.com>
In-Reply-To: <200610171101.38690.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Also, (please correct me if I'm wrong) I didn't
> > think this would push the allocation over to the next entry in
> > 'malloc_sizes'.
> 
> Well, skbuff heads are allocated from dedicated kmem_cache 
> (skbuff_fclone_cache & skbuff_head_cache), and these caches are not 
> constrained by the sizes available in malloc_sizes. Their 
> size are a multiple 
> of L1 CACHE size, which is 64 bytes for most common machines.

Indeed, struct skbuff is so allocated.  But I added the callback
pointers to struct skb_shared_info where the page pointers are stored,
and this struct is allocated along with the packet header using kmalloc.

> Even if your two pointers addition (16 bytes on x86_64) 
> doesnt cross a 64bytes 
> line (I didn't checked), they are going to be set to NULL 
> each time a skbuff 
> is allocated , and checked against NULL each time a skbuff is 
> destroyed.

Indeed.  Do you think that's significant?

                Cheers,
                        Eric

---------------------------------------------------
|Eric Barton        Barton Software               |
|9 York Gardens     Tel:    +44 (117) 330 1575    |
|Clifton            Mobile: +44 (7909) 680 356    |
|Bristol BS8 4LL    Fax:    call first            |
|United Kingdom     E-Mail: eeb@bartonsoftware.com|
---------------------------------------------------


