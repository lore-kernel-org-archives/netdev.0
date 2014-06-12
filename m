From: Cong Wang <cwang@twopensource.com>
Subject: Re: hard_header_len vs needed_headroom
Date: Thu, 12 Jun 2014 11:42:02 -0700
Message-ID: <CAHA+R7Nc7G1m7sJUgGOUY3=w6zdy07cmaBpoYAY7px0jP9UupA@mail.gmail.com>
References: <CAHA+R7Nyi9TvpN+fJrFt7krhLLXyJ5ify1ONvAse+rJFU0kbKg@mail.gmail.com>
	<CALnjE+pNfhB_-o1POjDpJj2F3opUv7ei1U8uO+bacCoP5vwxHg@mail.gmail.com>
	<CAHA+R7NERb0ZDbw7CX73A9VQSHs-+5DBfe=1-4rjPpoOGpnk8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:52294 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaFLSmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 14:42:04 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2644552qcz.0
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 11:42:03 -0700 (PDT)
In-Reply-To: <CAHA+R7NERb0ZDbw7CX73A9VQSHs-+5DBfe=1-4rjPpoOGpnk8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 9, 2014 at 4:37 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> It's not whether LL_RESERVED_SPACE() is used or not, it's whether
> dev->hard_header_len is always the offset from mac_header to
> network_header. mirred is not alone, tpacket_fill_skb() uses this as well.
> So I think we have to fix dev->hard_header_len for tunnels.

Thinking a bit more, I think this behavior is correct, the mirror device should
see the same packets as the tunnel device, that means for ipip tunnel its
dev->hard_header_len should be 0. vxlan tunnel needs to fix actually.
