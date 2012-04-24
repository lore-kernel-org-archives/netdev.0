From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Tue, 24 Apr 2012 04:59:32 +0200
Message-ID: <1335236372.5205.106.camel@edumazet-glaptop>
References: <1335201102.5205.28.camel@edumazet-glaptop>
	 <CADVnQy=igJdbcG4J2HU7nEJUNM84qVcLa08h6g6MQQ8-fvgxHg@mail.gmail.com>
	 <20120423.224602.594997774992725103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, therbert@google.com,
	maze@google.com, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58264 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab2DXC7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:59:37 -0400
Received: by wgbdr13 with SMTP id dr13so189713wgb.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:59:36 -0700 (PDT)
In-Reply-To: <20120423.224602.594997774992725103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 22:46 -0400, David Miller wrote:

> Applied, thanks Eric.
> 
> Although I'd like to ask you to clean up tcp_try_coalesce() a bit.
> 
> It effectively returns a boolean, but you've clouded this up by
> returning an int and defining it in the comment to return "> 0" or
> not.
> 
> Just make it return a real bool.
> 
> I know why you did this, it makes the "eaten" code somewhat simpler in
> tcp_data_queue(), but overall it's more confusing how it is now.
> 
> People look at how the tcp_try_coalesce() return value is interpreted
> and say "in what cases can it return a negative value?"  We both know
> it can't, but you have to read the entire function to figure that out.
> 
> And that's by definition not intuitive.
> 
> Thanks.

Sure I'll do the cleanup. You guessed correctly why I did that ;)

In the beginning I did a "return len;" instead of "return 1;" and felt a
bit uncomfortable in case we merged a zero length message.

Then I added the !th->fin test inside tcp_try_coalesce()

(my initial patch allowed the fin being set for the tcp_data_queue()
case since tcp_fin() was called anyway)

Thanks
