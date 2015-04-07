From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Mon, 6 Apr 2015 21:45:45 -0700
Message-ID: <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
References: <20150406.124114.924455461962119301.davem@davemloft.net>
	<20150406.131700.185460014498109286.davem@davemloft.net>
	<CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>
	<20150406.235118.65925113152002205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35621 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbDGEpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 00:45:46 -0400
Received: by iggg4 with SMTP id g4so2727643igg.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 21:45:45 -0700 (PDT)
In-Reply-To: <20150406.235118.65925113152002205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 8:51 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 6 Apr 2015 19:43:11 -0700
>
>> To be honest, requiring an additional socket to transmit UDP
>> encapsulation seems really convoluted to me, especially considering
>> that this is just trying trying to solve AF_PACKET in nf which seems
>> like a narrow use case.  Is there no way to test for AF_PACKET sockets
>> and take action at a lower function?  Does every type encapsulation
>> need its own UDP socket, or can you just have one which set from the
>> udp_tunnel when family of skb->sk is AF_PACKET?
>
> This has nothing to do with netfilter.
>
> This has everything to do with being able to pass a socket down
> through the complete ipv4/ipv6 output path.  That's the only
> reason netfilter needed to be touched.
>
> The ipv4/ipv6 output call paths have the NF hooks in the middle, and
> the NF hooks determine what the call signature is for the rest of the
> output path.  That's why it needed to be adjusted.
>
> For ipv6 fragmentation, in particular, having the right ipv4/ipv6
> socket is going to be important.
>
> AF_PACKET is not an isolated case, just the most likely example.  It's
> just as easy to trigger this problem for other protocol families too.
> You can send appletalk packets over VXLAN.
>
> I don't see what is convoluted about using the correct socket for
> sending L3 protocol frames.  That's in fact how it's _supposed_ to
> work.  And consistently having a proper matching socket available
> makes it so that, long-term, we'll never have to deal with this issue
> ever again.

I guess this is where I'm confused. We can send just about anything
over GRE also, but have never needed a transmit socket for that. Is
UDP encapsulation so different, or is GRE equally broken also? Also,
will we need to add the socket to FOU and GUE then?

Thanks,
Tom
