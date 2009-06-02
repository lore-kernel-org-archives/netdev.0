From: David Miller <davem@davemloft.net>
Subject: Re: potential null dereference in proto_register()
Date: Tue, 02 Jun 2009 02:54:54 -0700 (PDT)
Message-ID: <20090602.025454.127590436.davem@davemloft.net>
References: <alpine.DEB.2.00.0905271607370.11440@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36861
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759893AbZFBJyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:54:54 -0400
In-Reply-To: <alpine.DEB.2.00.0905271607370.11440@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 2 Jun 2009 11:50:52 +0300 (EAT)

> There is a potential null dereference in proto_register() 
> from net/core/sock.c
> 
> prot->rsk_prot can be null on line 2161 but we dereference it on line 
> 2167.
> 
>   2161  out_free_request_sock_slab:
>   2162          if (prot->rsk_prot && prot->rsk_prot->slab) {
>   2163                  kmem_cache_destroy(prot->rsk_prot->slab);
>   2164                  prot->rsk_prot->slab = NULL;
>   2165          }
>   2166  out_free_request_sock_slab_name:
>   2167          kfree(prot->rsk_prot->slab_name);
> 
> Found by smatch.

This won't ever happen because a protocol that provides a twsk_prot
has to provide a rsk_prot too.
