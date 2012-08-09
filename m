From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug with IPv6-UDP address binding
Date: Thu, 09 Aug 2012 13:37:50 +0200
Message-ID: <1344512270.28967.719.camel@edumazet-glaptop>
References: <1344458238.3069.13.camel@localhost>
	 <1344459591.28967.271.camel@edumazet-glaptop>
	 <1344505205.3069.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51107 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973Ab2HILhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 07:37:55 -0400
Received: by bkwj10 with SMTP id j10so129634bkw.19
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 04:37:54 -0700 (PDT)
In-Reply-To: <1344505205.3069.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 11:40 +0200, Jesper Dangaard Brouer wrote:

> Yes, I guess its an application bug, because Berkely-derived
> implementations don't handle multihomeing well for UDP.
> 
> Why are we keeping this, counter-intuitive behavior? 
> 

Because the BSD api has no other choice.

> What about changing the implementation to act like Solaris, which IMHO
> makes much more sense?
> 
> (BTW, iperf also have this "bug")
> 

Please describe how connect() is able to correctly chose for you a
source address, if you have say 256 addresses.

connect() API only requires the destination.

If you want a precise source, you must use bind() before the connect()

Any UDP application wanting to correctly reflect "correct source IP"
must say so to the kernel.

I dont think kernel could magically help here, really.
