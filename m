From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Tue, 07 Apr 2015 13:27:33 +0200
Message-ID: <1428406053.3932555.250169221.75848497@webmail.messagingengine.com>
References: <20150406.124114.924455461962119301.davem@davemloft.net>
 <20150406.131700.185460014498109286.davem@davemloft.net>
 <CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>
 <20150406.235118.65925113152002205.davem@davemloft.net>
 <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org,
	=?UTF-8?Q?Ji=C5=99=C3=AD=20P=C3=ADrko?= <jiri@resnulli.us>
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46167 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752719AbbDGL1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 07:27:33 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 7D56220C90
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 07:27:29 -0400 (EDT)
In-Reply-To: <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 7, 2015, at 06:45, Tom Herbert wrote:
> On Mon, Apr 6, 2015 at 8:51 PM, David Miller <davem@davemloft.net> wrote:
> > I don't see what is convoluted about using the correct socket for
> > sending L3 protocol frames.  That's in fact how it's _supposed_ to
> > work.  And consistently having a proper matching socket available
> > makes it so that, long-term, we'll never have to deal with this issue
> > ever again.
> 
> I guess this is where I'm confused. We can send just about anything
> over GRE also, but have never needed a transmit socket for that. Is
> UDP encapsulation so different, or is GRE equally broken also? Also,
> will we need to add the socket to FOU and GUE then?

GRE, FOU, GUE in case of sk_mc_loop and the destination is a multicast
address, we imply sk_mc_loop() == true, what is not what we want. Tunnel
sockets deliberately set mc_loop to false but we cannot adhere to them,
yet. David's patchset changes that.

Also, I saw one inconsistency with sk_bound_dev_if in netfilter which
doesn't get solved by this patchset (it uses skb->sk->sk_bound_dev_if
unconditionally).

I think that having a struct-sock carrying over meta-information is a
good thing.

Thanks,
Hannes
