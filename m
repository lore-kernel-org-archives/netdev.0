From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Sun, 5 Jan 2014 21:56:49 +0200
Message-ID: <CAJZOPZJh9Z2G5VtDX3x37bCXmVXaKxbaQPhKLrAwo9G_01ZYNg@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	<CAJZOPZKJvpk9ZW6iRnXzm9OHppStAF+2=COw3zWNy5rMy3r0qg@mail.gmail.com>
	<1388951306.12212.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45710 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaAET4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:56:49 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so17680681pbc.20
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 11:56:49 -0800 (PST)
In-Reply-To: <1388951306.12212.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 9:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-01-05 at 21:39 +0200, Or Gerlitz wrote:
>
>> To be accurate here, V1 (this patch) still has RFC aspects -- it
>> suggests a solution to the above matter -- the gro udp code exports
>> two callbacks which are invoked by the vxlan driver to add/delete udp
>> listening port. The callbacks maintain an O(1) accessed array which is
>> beeing looked from the fast path to determine if the destination udp
>> port of the packet under inspection is a vxlan listening port.
>
> This implementation uses a u8 for 64K ports, I am pretty sure you could
> use a bitmap instead so that a UDP forwarding workload do not need to
> bring 64KB in cpu caches, but only 8KB.

sure, I'll fix that V2.
