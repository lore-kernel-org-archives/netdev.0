From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Sun, 13 Mar 2016 19:29:58 -0700
Message-ID: <CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net> <20160313.215033.17951850162749485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mahesh@bandewar.net, Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:36458 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbcCNCaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:30:19 -0400
Received: by mail-yw0-f174.google.com with SMTP id g3so151850435ywa.3
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 19:30:18 -0700 (PDT)
In-Reply-To: <20160313.215033.17951850162749485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 6:50 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <mahesh@bandewar.net>
> Date: Wed,  9 Mar 2016 13:49:49 -0800
>
>> This does happen as expected for egress traffic however on ingress
>> traffic, the IPvlan packet-handler changes the skb->dev and this
>> forces packet to be processed with the IPvlan slave and it's
>> associated ns. This causes above mentioned problem and few other
>> which are not yet reported / attempted. e.g.  IPsec with L3 mode or
>> even ingress routing.
>
> And now your changes make it so that we can't run netfilter rules on
> the slave's device within the slave's ns.
>
> If someone is doing that now you're breaking things for them.
>
Yes, I agree. If someone is using netfilter hooks in slave-ns, then this would
break for them. If we do this as a separate mode (e.g. L3s) keeping the
current mode as it is. Would that be an acceptable solution?

> It doesn't matter whether doing so or not makes sense.
>
> You're going to have to find a way to do both, and also I'm concerned
> about how you're leaking the source namespace's "stuff" into the
> destination's.  That's very worrisome to me.
>
If we add a new mode (e.g. L3s) and preserve current mode as is it, then
that should address your first concern.

Now about leaking ns "stuff". I do not want to leak stuff across ns. In the
current L3 mode there is an issue that Nicolas has pointed out and I'll fix
that soon. In the new mode (L3s); right from the beginning the L2 and L3
processing always (and consistently) will happen with master device
(proposed skb->dev->l3_dev).

> There is no way I'm applying this as-is, sorry.
