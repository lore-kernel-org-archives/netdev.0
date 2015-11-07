From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sat, 07 Nov 2015 11:06:05 -0800
Message-ID: <1446923165.17135.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1446842228.git.daniel@iogearbox.net>
	 <5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
	 <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151107.133502.833614670001999282.davem@davemloft.net>
	 <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33138 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbbKGTGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 14:06:07 -0500
Received: by pabfh17 with SMTP id fh17so155862043pab.0
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 11:06:06 -0800 (PST)
In-Reply-To: <1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-11-07 at 10:53 -0800, Eric Dumazet wrote:


> Well, imagine following scenario (a real one, as I use it all of time,
> thus how I discovered all trafgen traffic ends up on one slave only)
> 
> Even if qdisc is bypassed on the bond0, the current handling does not
> prevent going to the slave qdiscs.
> 
> 
> So it is not clear to me why we do a selective probe depending on the
> bypass of first qdisc.

Presumably the transport_header only needs to be set for gso packets in
some drivers (look at igbvf_tso() for example)

It looks like we might need an audit and/or some guidelines/fixes.
