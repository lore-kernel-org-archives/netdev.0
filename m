From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Fri, 17 Jan 2014 14:18:46 -0800
Message-ID: <CAHA+R7Mj211P_YVnpMV6-Y+Bwh+reJvvZem5vDHB0Nqz96S1DA@mail.gmail.com>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:48510 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbaAQWSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 17:18:48 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so4012095lan.26
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 14:18:47 -0800 (PST)
In-Reply-To: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 4:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> This patch :
>
> 1) Remove a dst leak if DST_NOCACHE was set on dst
>    Fix this by holding a reference only if dst really cached.
>
> 2) Remove a lockdep warning in __tunnel_dst_set()
>     This was reported by Cong Wang.
>
> 3) Remove usage of a spinlock where xchg() is enough
>
> 4) Remove some spurious inline keywords.
>    Let compiler decide for us.

5) remove the unless NULL'ing for percpu pointers. :)

Looks good.

Thanks!
