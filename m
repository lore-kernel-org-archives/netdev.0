From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 11:01:38 +0200
Message-ID: <200610171101.38690.dada1@cosmosbay.com>
References: <019c01c6f186$99d0d6b0$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40648 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1423170AbWJQJBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 05:01:41 -0400
To: "Eric Barton" <eeb@bartonsoftware.com>
In-Reply-To: <019c01c6f186$99d0d6b0$0281a8c0@ebpc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 October 2006 02:53, Eric Barton wrote:
> If so, do you have any ideas about how to do it more economically?  It's 2
> pointers rather than 1 to avoid forcing an unnecessary packet boundary
> between successive zero-copy sends.  But I guess that might not be hugely
> significant since you're generally sending many pages when zero-copy is
> needed for performance.  Also, (please correct me if I'm wrong) I didn't
> think this would push the allocation over to the next entry in
> 'malloc_sizes'.

Well, skbuff heads are allocated from dedicated kmem_cache 
(skbuff_fclone_cache & skbuff_head_cache), and these caches are not 
constrained by the sizes available in malloc_sizes. Their size are a multiple 
of L1 CACHE size, which is 64 bytes for most common machines.

Even if your two pointers addition (16 bytes on x86_64) doesnt cross a 64bytes 
line (I didn't checked), they are going to be set to NULL each time a skbuff 
is allocated , and checked against NULL each time a skbuff is destroyed.

Eric
