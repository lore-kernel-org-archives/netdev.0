From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for TCP
Date: Tue, 24 Apr 2012 09:44:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EEF@saturn3.aculab.com>
References: <1335213446.5205.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <rick.jones2@hp.com>, <netdev@vger.kernel.org>,
	<therbert@google.com>, <ncardwell@google.com>, <maze@google.com>,
	<ycheng@google.com>, <ilpo.jarvinen@helsinki.fi>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56723 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755270Ab2DXIoy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:44:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09862-08 for <netdev@vger.kernel.org>;
 Tue, 24 Apr 2012 09:44:49 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1335213446.5205.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> On Mon, 2012-04-23 at 16:01 -0400, David Miller wrote:
> 
> > Hmmm... why don't we just acknowledge reality and special case ACKs?
> > 
> 
> Yes why not.
> 
> 
> > If a TCP packet is dataless we should just let it go 
> > through no matter what and with no limits.
> >  It is by definition transient and will not
> > get queued up into the socket past this backlog stage.
> > 
> 
> Even being transient we need a limit. Without copybreak, an 
> ACK can cost 2048+256 bytes.
> 
> In my 10Gbit tests (standard netperf using 16K buffers), I've seen
> backlogs of 300 ACK packets...

What about forcing a copybreak for acks when above the rx buffer size?
That way you avoid the cost of the copy in teh normal case when
the data will be freed, but avoid the memory overhead when a lot
of acks (or rx data) is queued.

	David
