From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: udp4: move GSO functions to udp_offload
Date: Mon, 24 Jun 2013 03:25:39 -0700
Message-ID: <1372069539.3301.55.camel@edumazet-glaptop>
References: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
	 <1372063295.3301.52.camel@edumazet-glaptop> <51C80886.9000307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46630 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab3FXKZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 06:25:45 -0400
Received: by mail-bk0-f46.google.com with SMTP id na10so4085836bkb.5
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 03:25:43 -0700 (PDT)
In-Reply-To: <51C80886.9000307@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 10:51 +0200, Daniel Borkmann wrote:
> On 06/24/2013 10:41 AM, Eric Dumazet wrote:
> >
> > Daniel, the same could be done for GRE, ie moving GSO stuff into
> > net/ipv4/gre_offload.c
> >
> > Tell me if you do not have the time to do this, I will handle it.
> 
> Ok, I can do this today.

Thanks !

Oh well, there is a bug in gre_gso_segment(), we need to fix it before
considering this gre_offload.c separation.

if __skb_linearize() fails, kfree_skb(segs); is not really doing the
right thing.
