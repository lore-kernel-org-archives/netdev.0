From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 11:00:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920010055.GA10793@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au> <414DF111.3080409@eurodev.net> <20040919215328.GA9573@gondor.apana.org.au> <414E0CE6.107@eurodev.net> <20040919234445.GC10124@gondor.apana.org.au> <414E24E4.1020104@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, jamal <hadi@cyberus.ca>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414E24E4.1020104@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 02:31:32AM +0200, Pablo Neira wrote:
> 
> >There is no point for the kernel to wait at all.  For unicast sockets
> >used for sending commands to the kernel, you should never get overruns
> >if you are reading your responses correctly and have set the queue size
> >correctly.
> 
> sure, not for commands. When I talk about netlink sockets, I'm not 
> focused on commands because what they do currently is quite enough for 
> them I think. I know that commands are the main application of netlink 
> sockets but there are many others.

My message was in response to your problem a) which looks exactly like
a command.

> >>b) A module needs to send a lot of information from kernel space to user 
> >>space, if buffer gets full quickly, buffer overruns and 
> >>netlink_unicast/broadcast never wait, so they drop packets.
>
> In that case, netlink buffer will surely overrun, so those 300 messages 
> will be drop because kernel didn't wait a bit. This is what happens now, 
> I can reproduce this with my tool.

Well I see two solutions.  You either extend the receive queue or tell the
kernel to stop sending.  The second is not an option here because you'll
lose the packets anyway.

Getting the kernel to wait is NOT a solution.  It's just another form of
extending the receive queue, albeit an ugly one.

But hang on a second, the kernel should've woken up your process after the
very first message.  Why isn't that happening?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
