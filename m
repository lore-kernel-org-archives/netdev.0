From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 12:17:36 -0800
Message-ID: <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f175.google.com ([209.85.161.175]:61130 "EHLO
	mail-gg0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbaAMURm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:17:42 -0500
Received: by mail-gg0-f175.google.com with SMTP id c2so1551492ggn.6
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 12:17:41 -0800 (PST)
In-Reply-To: <20140113.115913.1269834557058575064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 11:59 -0800, David Miller wrote:

> It also doesn't jive well with Eric's recent patch to adjust the GRO
> overflow strategy (600adc18eba823f9fd8ed5fec8b04f11dddf3884 ("net:
> gro: change GRO overflow strategy"))
> 
> :-)
> 
> I sort of like Tom's idea to optimistically compare the hash, if we
> do in fact have one already.
> 
> Eric would the change be OK if Tom did it that way?
> --

Yes this is what I suggested, but it seems Tom had something different
in mind.

I would rather not call flow dissector from GRO, especially considering
nobody but Google uses RPS/RFS (otherwise CVE-2013-4348 would have been
discovered much sooner)
