From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Thu, 29 Nov 2012 15:32:16 -0800
Message-ID: <1354231936.3299.50.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55412 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab2K2XhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 18:37:22 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7988495pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 15:37:22 -0800 (PST)
In-Reply-To: <1354227470.11754.348.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 23:17 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 2012-11-29 at 12:44 -0500, David Miller wrote:

> It is VERY important that you understand/realize that throwing more
> memory at the problem is NOT the solution.  It a classical queue theory
> situation where the arrival rate is bigger than the processing
> capabilities. Thus, we must drop packets, or else the NIC will do it for
> us... for fragments we need do this "dropping" more intelligent.

Thats the typical head/tail drop choice. There is no bad/good choice.

Implementing head drop or tail drop is not a matter of only dealing with
regular traffic. We also can face DOS attacks, with packets of different
sizes and have to choose a compromise.

For example, it seems we have no protection against an attack using
small frags (but big truesize). So a particular 'packet' could consume
all the truesize we allowed for the whole frags queue.

skb_try_coalesce() cant always deal with this kind of thing.

Basically, thats why using frags in the first place is a bad choice.
