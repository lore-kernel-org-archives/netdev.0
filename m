From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: TCP fragmentation broken in 3.6-rc ?
Date: Mon, 20 Aug 2012 17:14:30 +0200
Message-ID: <1345475670.5158.322.camel@edumazet-glaptop>
References: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
	 <CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62247 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671Ab2HTPOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 11:14:35 -0400
Received: by bkwj10 with SMTP id j10so1892229bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 08:14:34 -0700 (PDT)
In-Reply-To: <CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 16:56 +0200, Sylvain Munaut wrote:
> Hi,
> 
> It seems somehow something was broken in 3.6-rc.
> I'm not sure exactly what though. The symptoms are:
> 
>  - TCP connection get "stuck" with data in send queue when doing
> "large" transfers ( like typing 'ps ax' on a ssh connection )
>  - Only happens on path where the PMTU is lower than the MTU of the interface
>  - Is not present right after boot, it only appears 10-20min after
> boot or so. (and that's inside the _same_ TCP connection, it works
> fine at first and then in the same ssh session, it'll get stuck)
>  - Definitely seems related to fragments somehow since I see a router
> sending ICMP message saying fragmentation is needed.
>  - Exact same setup works fine with kernel 3.5.1
> 
> Cheers,

Could you make sure its not a pfmemalloc problem, by applying following
patch :

https://lkml.org/lkml/2012/8/20/182

Thanks
