From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mlx4 netpoll and rx/tx weirdness
Date: Mon, 17 Mar 2014 14:40:10 -0700
Message-ID: <1395092410.9668.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140315.122912.1621610280186900725.davem@davemloft.net>
	 <87ob17kz96.fsf_-_@xmission.com>
	 <1394986621.9668.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317.172230.76193310497948256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ben@decadent.org.uk, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	amirv@mellanox.com, ogerlitz@mellanox.com, jackm@dev.mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:35992 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbaCQVkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:40:14 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so6273716pbc.32
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 14:40:13 -0700 (PDT)
In-Reply-To: <20140317.172230.76193310497948256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 17:22 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 16 Mar 2014 09:17:01 -0700
> 
> > Wait a minute, I thought ndo_poll_controller() had to be synchronous,
> > not schedule a napi ?
> 
> ndo_poll_controller() basically runs the hardware interrupt handler,
> which might schedule NAPI processing.  Then netpoll invokes
> the NAPI poll in whatever state ndo_poll_controller() left it in.

Ah right, this makes sense, poll_napi() uses a spin_trylock()...
