From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Three way TCP handshake : can we avoid the third packet ?
Date: Tue, 12 Oct 2004 10:41:43 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410121030150.22884@filer.marasystems.com>
References: <41504117.9010108@cosmosbay.com> <Pine.LNX.4.61.0409211838390.31157@filer.marasystems.com>
 <415136D1.7030600@cosmosbay.com> <416B92BC.1010504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <416B92BC.1010504@cosmosbay.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2004, Eric Dumazet wrote:

> Following this discussion on netdev, sorry to bother you again :)
>
> Currently, linux cannot easily avoids the third packet (ACK only) of TCP 
> handshake, for connections initiated from linux side.
>
> The send(socket, data) is denied (EAGAIN) if the socket is in NODELAY mode 
> and socket not yet connected  (connect() done , but not in ESTABLISHED 
> state).

This is my observations as well.

> So basically, a daemon willing to avoid the third packet must use one thread 
> for each outgoing pending connection, seting the socket in blocking mode and 
> blocking in send()/write() syscall. In my case, I would need about 1000 
> threads :(
>
> Could we just delay (say up to 200ms) the ACK packet the tcp stack sends ?

What would this do to the initial RTT measurements?

>From what I can see the RFCs only allow for delayed ACKs in response to a 
data segment. Not sure if this includes SYN (or FIN).

Regards
Henrik
