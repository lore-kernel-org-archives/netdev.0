From: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Tue, 28 Feb 2012 11:47:39 +0100
Message-ID: <1330426059.2139.21.camel@megeve>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
	 <20120224.153616.117399887784547022.davem@davemloft.net>
	 <4F4B8C66.5060206@collabora.co.uk>
	 <20120227.140535.1623396420455657443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: javier.martinez@collabora.co.uk, javier@collabora.co.uk,
	eric.dumazet@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120227.140535.1623396420455657443.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

On Mon, 2012-02-27 at 14:05 -0500, David Miller wrote:
> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> Date: Mon, 27 Feb 2012 15:00:06 +0100
> 
> > Primary for performance reasons. D-bus is an IPC system for processes in
> > the same machine so traversing the whole TCP/IP stack seems a little
> > overkill to me.
> 
> You haven't actually tested what the cost of this actually is, so what
> you're saying is mere speculation.  In many cases TCP/UDP over
> loopback is actually faster than AF_UNIX.
> 
you're right we haven't tested this, but because of the other points in
Javier's mail, which are the special semantics we need for this to fit
the D-Bus usage:

> - total order is guaranteed: If sender A sends a message before B,
then
> receiver C and D should both get message A first and then B.
> 
> - slow readers: dropping packets vs blocking the sender. Although
>   datagrams are not reliable on IP, datagrams on Unix sockets are
never
>   lost. So if one receiver has its buffer full the sender is blocked
> instead of dropping packets. That way we guarantee a reliable
> communication channel.
> 
> - multicast group acess control: controlling who can join the
multicast
> group.
> 
> - multicast on loopback is not supported: which means we have to use a
> NIC (i.e: eth0). 

Because of all of this, UDP/IP multicast wasn't even considered as an
option. We might be wrong in some/all of those, so could you please
comment on them to check if that's so?

thanks
