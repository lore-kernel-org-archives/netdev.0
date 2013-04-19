From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 04:14:50 -0700
Message-ID: <1366370090.3205.109.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B71EB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:60000 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967926Ab3DSLOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 07:14:53 -0400
Received: by mail-pb0-f54.google.com with SMTP id xa7so64251pbc.41
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 04:14:53 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71EB@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 11:41 +0100, David Laight wrote:
> > The 64 slots hash table was chosen years ago, when machines had 3 order
> > of magnitude less ram than today.
> > 
> > Before hash resizing, I would just bump hash size to something more
> > reasonable like 1024.
> 
> While that is true of many systems, there are embedded systems
> with much less ram than the typical x86 desktop or server.
> 
> There seem to be quite a lot of large hash tables appearing
> that on many small systems will never contain a significant
> number of entries and just waste precious memory.

Embedded systems run linux since ages, and their memory also increased
by 2 order of magnitude since 1995.

If they run linux-3.10, using 4096 bytes of 8192 bytes for the hash
table is fine.

We are not going to add yet another ifdef, for such a small amount of
ram.

The code that we will add to do the resize will be larger than this.
