From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 06:57:25 -0800
Message-ID: <1354287445.3299.72.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354276891.11754.424.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au,
	David Laight <David.Laight@ACULAB.COM>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60246 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab2K3O53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 09:57:29 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so739955ieb.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 06:57:29 -0800 (PST)
In-Reply-To: <1354276891.11754.424.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 13:01 +0100, Jesper Dangaard Brouer wrote:

> As the existing entries in the frag queues, are still being allowed
> packets through (even when the memory limit is exceeded).   In
> worst-case, as DaveM explained, this can be as much as 100KBytes per
> entry (for 64K fragments).

Some NIC uses a plain page to hold an ethernet frame.

Consider an UDP packet using 512 bytes frags, the resulting packet after
reassembly can use 128 pages. Thats 512 KB of memory on x86.
