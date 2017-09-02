From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bpf: sockmap update/simplify memory
 accounting scheme
Date: Fri, 01 Sep 2017 20:29:51 -0700 (PDT)
Message-ID: <20170901.202951.1362873321102324036.davem@davemloft.net>
References: <20170901182926.8981.77450.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdIBD3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 23:29:52 -0400
In-Reply-To: <20170901182926.8981.77450.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 01 Sep 2017 11:29:26 -0700

> Instead of tracking wmem_queued and sk_mem_charge by incrementing
> in the verdict SK_REDIRECT paths and decrementing in the tx work
> path use skb_set_owner_w and sock_writeable helpers. This solves
> a few issues with the current code. First, in SK_REDIRECT inc on
> sk_wmem_queued and sk_mem_charge were being done without the peers
> sock lock being held. Under stress this can result in accounting
> errors when tx work and/or multiple verdict decisions are working
> on the peer psock.
> 
> Additionally, this cleans up the code because we can rely on the
> default destructor to decrement memory accounting on kfree_skb. Also
> this will trigger sk_write_space when space becomes available on
> kfree_skb() which wasn't happening before and prevent __sk_free
> from being called until all in-flight packets are completed.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
