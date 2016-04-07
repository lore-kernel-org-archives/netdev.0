From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: optimizations to sk_buff handling in rds_tcp_data_ready
Date: Thu, 7 Apr 2016 15:29:46 -0400
Message-ID: <20160407192946.GA10957@oracle.com>
References: <20160407130859.GA2818@oracle.com>
 <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, tom@herbertland.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27393 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbcDGT36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 15:29:58 -0400
Content-Disposition: inline
In-Reply-To: <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/07/16 07:16), Eric Dumazet wrote:
> Use skb split like TCP in output path ?

That almost looks like what I want, but skb_split modifies both
skb and skb1, and I want to leave skb untouched (otherwise 
I will mess up the book-keeping in tcp_read_sock). But skb_split 
is a good template- I think it could even be extended to avoid copying
the frags that we'd later trim off in rds_tcp_data_recv anyway, 
let me see what I can come up with, based on that code.

> Really, pskb_expand_head() is not supposed to copy payload ;)

That would make my world very easy! But it has callers from all
over the kernel, e.g., skb_realloc_headroom, and changing it is
obviously risky
