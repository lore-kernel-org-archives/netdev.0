From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sat, 07 Nov 2015 10:53:50 -0800
Message-ID: <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1446842228.git.daniel@iogearbox.net>
	 <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
	 <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151107.133502.833614670001999282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35586 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbbKGSxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:53:52 -0500
Received: by pasz6 with SMTP id z6so159879782pas.2
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 10:53:51 -0800 (PST)
In-Reply-To: <20151107.133502.833614670001999282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-11-07 at 13:35 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 07 Nov 2015 04:42:56 -0800
> 
> > The if (!packet_use_direct_xmit(po)) test looks dubious.
> > 
> > Setting transport header has nothing to do with bypassing qdisc ?
> > 
> > This might lead to hard to debug problems, for drivers expecting
> > transport header being set ?
> 
> Do we have any such drivers that need it in this scenerio?

Well, imagine following scenario (a real one, as I use it all of time,
thus how I discovered all trafgen traffic ends up on one slave only)

Even if qdisc is bypassed on the bond0, the current handling does not
prevent going to the slave qdiscs.


So it is not clear to me why we do a selective probe depending on the
bypass of first qdisc.
