From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Mon, 6 Apr 2015 19:43:11 -0700
Message-ID: <CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>
References: <20150405.221847.2119086885797169021.davem@davemloft.net>
	<CALx6S348YyYxrT+3fcXEFz=w6BYFGZwcQ6iD1PjzVePotioJKw@mail.gmail.com>
	<20150406.124114.924455461962119301.davem@davemloft.net>
	<20150406.131700.185460014498109286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33891 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbbDGCnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 22:43:12 -0400
Received: by iedfl3 with SMTP id fl3so41068440ied.1
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 19:43:11 -0700 (PDT)
In-Reply-To: <20150406.131700.185460014498109286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 6, 2015 at 10:17 AM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 06 Apr 2015 12:41:14 -0400 (EDT)
>
>> Tom if you are saying that skb->sk should be reset to the tunnel
>> socket, that doesn't work and is completely broken.
>
> Thinking some more, I think what you are missing is that deeper in the
> ipv4/ipv6 transmit call chain we do things like sk_mc_loop() etc. on
> the socket and we cannot just do it on skb->sk.
>
> To make that work correctly we must pass the tunnel socket down
> through the ipv4/ipv6 packet output paths, via netfilter hooks
> if necessary.
>
> I am also really disappointed with the call signature of the udp
> tunnel send paths.  You have to be honest with yourself and agree
> that something with 11 arguments is not a well designed interface.
>
> Now that hopefully you can see that the socket is actually required,
> can possibly use that to trim the function signature down for
> udp_tunnel{,6}_xmit_skb()?
>
To be honest, requiring an additional socket to transmit UDP
encapsulation seems really convoluted to me, especially considering
that this is just trying trying to solve AF_PACKET in nf which seems
like a narrow use case.  Is there no way to test for AF_PACKET sockets
and take action at a lower function?  Does every type encapsulation
need its own UDP socket, or can you just have one which set from the
udp_tunnel when family of skb->sk is AF_PACKET?

Thanks,
Tom

> Worst case, make a "struct udp_tunnel_state" just like I made a "struct
> nf_hook_state" for the netfilter hooks.
>
> Thanks.
