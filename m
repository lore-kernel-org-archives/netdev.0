From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [CRIU] linux-next: WARNING: CPU: 0 PID: 2825 at
 net/ipv4/tcp_input.c:3078 tcp_ack+0x11f5/0x1380()
Date: Mon, 11 Aug 2014 17:55:20 +0200
Message-ID: <1407772520.10122.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANaxB-x7UVwLUi6RwQ9fU_j-AB3jhBmFehis-+XVaHet4wmsLg@mail.gmail.com>
	 <1407766352.10122.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140811153706.GD22836@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Wagin <avagin@gmail.com>,
	"criu@openvz.org" <criu@openvz.org>, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41428 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbaHKPzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 11:55:23 -0400
Received: by mail-pa0-f46.google.com with SMTP id lj1so11232423pab.19
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 08:55:23 -0700 (PDT)
In-Reply-To: <20140811153706.GD22836@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-11 at 19:37 +0400, Andrew Vagin wrote:

> Yes, it does. We hope that tcp code will fix rtt according with next
> packages.

I don't think its the right way.

You only used cubic, but some congestion modules heavily depends on rtt.

Cleaner way would be to not try to use wrong RTT estimations in the
first place.

skb_mstamp being NULL is exactly the mark of skb that should not
participate in the rtt estimations.

(or use a new flag , included in TCPCB_RETRANS )
