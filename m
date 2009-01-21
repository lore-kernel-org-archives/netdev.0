From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fwd: iproute2 wrong burst/cburst calculation?
Date: Wed, 21 Jan 2009 09:48:43 +0000
Message-ID: <20090121094843.GA5140@ff.dom.local>
References: <200901202257.11773.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:55077 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbZAUJsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 04:48:51 -0500
Received: by ey-out-2122.google.com with SMTP id 22so658260eye.37
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 01:48:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901202257.11773.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 10:57:11PM +0200, Denys Fedoryschenko wrote:
...
> class htb 1:3 parent 1:2 leaf 3: prio 0 quantum 200000 rate 680000Kbit ceil 
> 950000Kbit burst 1445b/8 mpu 0b overhead 0b cburst 1425b/8 mpu 0b overhead 0b 
> level 0
>  Sent 140533370 bytes 200327 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 52228Kbit 9289pps backlog 0b 0p requeues 0
>  lended: 199720 borrowed: 607 giants: 0
>  tokens: 17 ctokens: 12
> 
> So just look: 1:3 have burst 1445 / 1425, and 1:2, his parent - burst 1425 and 
> cburst 1425. It is wrong? I am not so experienced in htb to judge, but i feel 
> like iproute2 calculating burst/cburst not right way. 
...
> I guess it was supposed in this formula, that size must vary, and higher rate 
> must have higher size. But because our timer resolution so high, and we add 
> also mtu value... things going wrong.
> I dont know yet, how to calculate this correctly. Even not sure if it is 
> wrong. But HTB author, stated clearly 

Denys, I can't verify this all anytime soon, but most likely you are
right. Lower burst/cburst for higher rates means there have to be some
overflow, but since I think you know tc better than me, probably a
patch is needed. (Then one of possible "fast" fixes could be probably
to check for some max rate which doesn't overflow yet.)

Thanks,
Jarek P.
