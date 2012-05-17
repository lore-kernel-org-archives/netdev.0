From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 18:33:24 +0200
Message-ID: <1337272404.3403.18.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44900 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696Ab2EQQd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:33:29 -0400
Received: by eeit10 with SMTP id t10so589710eei.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 09:33:28 -0700 (PDT)
In-Reply-To: <20120517155621.GK14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 17:56 +0200, Willy Tarreau wrote:
> On Thu, May 17, 2012 at 05:43:00PM +0200, Eric Dumazet wrote:

> It's the NIC included in the system-on-chip (Marvell 88F6281), and the NIC
> driver is mv643xx. It's the same hardware you find in sheevaplugs, guruplugs,
> dreamplugs and almost all ARM-based cheap NAS boxes.
> 
> > With commit 1d0c0b328a6 in net-next
> > (net: makes skb_splice_bits() aware of skb->head_frag)
> > You'll be able to get even more speed, if NIC uses frag to hold frame.
> 
> I'm going to check this now, sounds interesting :-)

splice(socket -> pipe) does a copy of frame from skb->head to a page
fragment.

With latest patches (net-next), we can provide a frag for skb->head and
avoid this copy in splice(). You would have a true zero copy
socket->socket mode.

tg3 drivers uses this new thing, mv643xx_eth.c could be changed as well.
