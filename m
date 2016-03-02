From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: skb_under_panic in ip_tunnel_xmit
Date: Wed, 2 Mar 2016 10:56:52 -0800
Message-ID: <CA+HUmGiVexacGwDeRU8k2adFuDZPpOgcJ8PokOGT6HukDc6+Vw@mail.gmail.com>
References: <20160302171159.8A27C384B80@fruggeri-Arora18.sjc.aristanetworks.com>
	<1456942489.648.113.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33375 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbcCBS4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:56:53 -0500
Received: by mail-ob0-f169.google.com with SMTP id fz5so75575959obc.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:56:53 -0800 (PST)
In-Reply-To: <1456942489.648.113.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am not sure we want to support ~64K of headers.
>
> Is this something real, or just another root-exploit
> linux-bug-of-the-day trick ?
>
> When I want to reboot my host I usually type 'reboot', as it looks nicer
> to me ;)
>

Thanks Eric.
My point was that an accidental route misconfiguration, say by a buggy
protocol daemon (that is how we stumbled into this ... :( ) may leave
tunnel interfaces in an invalid state (namely with a very large or too
small needed_headroom) even after the misconfiguration is addressed.
The only fix at that point is to reinitialize the affected tunnel
interfaces, but it would not be obvious which tunnel interfaces were
affected or easy to debug a resulting crash.
The script itself is obviously not a realistic scenario, but in it I
was just trying to isolate a couple of points, namely that in the
presence of a bad routing configuration needed_headroom in tunnel
interfaces may become invalid and even result in a crash, and that
depending on the routing one may not even get a "Dead loop" warning
from dev_queue_xmit.
But I am ok if the consensus is that protocol daemons should just not do this.

Thanks,
Francesco
