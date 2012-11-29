From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 10:24:52 -0800
Message-ID: <1354213492.3299.22.camel@edumazet-glaptop>
References: <1354211004.3299.12.camel@edumazet-glaptop>
	 <20121129.124839.963269461515687321.davem@davemloft.net>
	 <1354211659.3299.15.camel@edumazet-glaptop>
	 <20121129.130506.329791401604974668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:39181 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab2K2SYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:24:55 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so5372503dak.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:24:55 -0800 (PST)
In-Reply-To: <20121129.130506.329791401604974668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 13:05 -0500, David Miller wrote:

> Replace 1024 in your formula with X and the limit is therefore
> controlled by X.
> 
> So it seems the high_thresh can be replaced with an appropriate
> determination of X to size the hash.
> 
> If X is 256, that limits us to ~130MB per cpu.
> 

per host, as the table would be shared by all cpus.

Lets say the default mem limit would be 4MB, I believe the
percpu_counter is cheap enough that we still allow a 1024 buckets table,
and allow receiving full size IP packets (If not under frag attack)

(If we divided 4MB by 64, we would have a 64KB limit per bucket, which
is too small because of truesize overhead)
