From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in
 tcpmss_tg6()
Date: Fri, 15 Jan 2016 21:04:16 +0100
Message-ID: <20160115200416.GA2331@salvia>
References: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
 <1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160115.140449.1324683966791337294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tom@herbertland.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42892 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551AbcAOUEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 15:04:21 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id E96E2261791
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 21:04:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DAB74DA85F
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 21:04:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E8549DA804
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 21:04:17 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20160115.140449.1324683966791337294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 02:04:49PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 15 Jan 2016 09:18:44 -0800
> 
> > On Fri, 2016-01-15 at 08:43 -0800, Tom Herbert wrote:
> > 
> >> Probably should have a utility function do this. Maybe something like
> >> update_hdr_field(skb, old, new)? Could return new value so above could
> >> just be:
> >> 
> >> ipv6h->payload_len = update_hdr_field(skb, ipv6h->payload_len,
> >> htons(ntohs(oldlen) + ret);
> > 
> > Well, oldlen would still need to be ipv6h->payload_len
> > 
> > Not sure a helper will be nice for a stable submission.
> > 
> > Probably better for net-next ?
> 
> Agreed.  We already have those csum_replace{2,4}() helpers in net/checksum.h
> which we could augment with ones that can handle length changes too.

I'm going to place this into the nf tree, thanks!
