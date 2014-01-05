From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan
 traffic
Date: Sun, 05 Jan 2014 11:48:26 -0800
Message-ID: <1388951306.12212.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	 <1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	 <CAJZOPZKJvpk9ZW6iRnXzm9OHppStAF+2=COw3zWNy5rMy3r0qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:58892 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaAETs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:48:28 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so17402618pdj.33
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 11:48:27 -0800 (PST)
In-Reply-To: <CAJZOPZKJvpk9ZW6iRnXzm9OHppStAF+2=COw3zWNy5rMy3r0qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-05 at 21:39 +0200, Or Gerlitz wrote:

> To be accurate here, V1 (this patch) still has RFC aspects -- it
> suggests a solution to the above matter -- the gro udp code exports
> two callbacks which are invoked by the vxlan driver to add/delete udp
> listening port. The callbacks maintain an O(1) accessed array which is
> beeing looked from the fast path to determine if the destination udp
> port of the packet under inspection is a vxlan listening port.

This implementation uses a u8 for 64K ports, I am pretty sure you could
use a bitmap instead so that a UDP forwarding workload do not need to
bring 64KB in cpu caches, but only 8KB.
