From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: reset skb queue mapping when rx'ing over tunnel
Date: Sat, 25 Sep 2010 08:49:10 +0200
Message-ID: <1285397350.2478.102.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009231415290.25121@pokey.mtv.corp.google.com>
	 <1285293960.2380.23.camel@edumazet-laptop>
	 <AANLkTimG9ZCZwDyo_9bYURShn7hk6ROzX4-qypo7nG5i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, chavey@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56031 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab0IYGtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 02:49:16 -0400
Received: by fxm3 with SMTP id 3so1105834fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 23:49:15 -0700 (PDT)
In-Reply-To: <AANLkTimG9ZCZwDyo_9bYURShn7hk6ROzX4-qypo7nG5i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 09:18 -0700, Tom Herbert a =C3=A9c=
rit :
> > Hmm...
> >
> > This would need to be reverted later when tunnels are updated to be
> > multiqueue aware ? I made an attempt with GRE some days ago.
> >
> > I dont understand why this patch is needed, since get_rps_cpu() has=
 a
> > check anyway
> >
> I think the skb queue_mapping should correspond to a queue in the
> skb's device as an invariant.  In the case that an skb's device is
> change from a multiqueue device to single queue device (like GRE), th=
e
> inconsistency in the queue_mapping is fairly innocuous, we get one
> warning but will pretty much take the unlikely branch for GRE packets
> then on.  But imagine a case where skb's device was change from one
> multiqueue device to another, but the queue mapping was not also
> updated.  This  would cause poor weighting in get_rps_cpus.  For
> example, if the new device had fewer queues than the old one,
> get_rps_cpu will bias toward using queue 0's rps mask.

I believe your patch is fine. Thanks

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


