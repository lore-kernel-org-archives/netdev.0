From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Wed, 22 Sep 2010 12:59:01 +0200
Message-ID: <20100922105901.GB16028@redhat.com>
References: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
 <20100912121349.GD22982@redhat.com>
 <20100914.202023.193706826.davem@davemloft.net>
 <20100915052332.GB25340@redhat.com>
 <AANLkTi=iYahjwZt5w53xFsU7fyHr72wXHd9tycwUiNE9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	socketcan@hartkopp.net, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099Ab0IVLFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Sep 2010 07:05:04 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=iYahjwZt5w53xFsU7fyHr72wXHd9tycwUiNE9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 22, 2010 at 05:35:07PM +0800, Changli Gao wrote:
> On Wed, Sep 15, 2010 at 1:23 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > Hmm, and there's another issue I think I see here:
> > destructor_arg now points to a socket.
> > What happens if the skb gets queued on an interface for a very long time
> > (as can be the case with e.g. tap), and meanwhile
> > you try to kill the task that owns the socket, which
> > will try to destroy the socket?
> >
> > Original code handles this by relevant devices orphaning an skb
> > if it's queued indefinitely.
> >
> 
> I don't think the skb_orphan() there is used to destroy the socket in
> time, but notify the socket that skbs are sent out and it can send new
> skbs.

Well, the result is that we drop a socket reference from the skb,
so it becomes possible to free the socket.

> -- 
> Regards,
> Changli Gao(xiaosuo@gmail.com)
