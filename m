From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 10:53:12 +0200
Message-ID: <1335257592.5205.131.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	maze@google.com, ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39917 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535Ab2DXIxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:53:19 -0400
Received: by bkuw12 with SMTP id w12so218666bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 01:53:18 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEF@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 09:44 +0100, David Laight wrote:
> > On Mon, 2012-04-23 at 16:01 -0400, David Miller wrote:
> > 
> > > Hmmm... why don't we just acknowledge reality and special case ACKs?
> > > 
> > 
> > Yes why not.
> > 
> > 
> > > If a TCP packet is dataless we should just let it go 
> > > through no matter what and with no limits.
> > >  It is by definition transient and will not
> > > get queued up into the socket past this backlog stage.
> > > 
> > 
> > Even being transient we need a limit. Without copybreak, an 
> > ACK can cost 2048+256 bytes.
> > 
> > In my 10Gbit tests (standard netperf using 16K buffers), I've seen
> > backlogs of 300 ACK packets...
> 
> What about forcing a copybreak for acks when above the rx buffer size?
> That way you avoid the cost of the copy in teh normal case when
> the data will be freed, but avoid the memory overhead when a lot
> of acks (or rx data) is queued.

Thats noise, as the minimal truesize of an ACK packet is 512 + 256 on
x86_64

The fact that ixgbe provides 1024 + 256 could be fixed in the driver,
its a 4 lines change actually. Then you already have a minimal skb.
