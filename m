From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 20:01:13 -0800
Message-ID: <1416974473.29427.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54752263.2040204@gmail.com>
	 <1416966185.29427.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141125.221900.653470310152197801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:42062 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbaKZEBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 23:01:16 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so1871735ieb.26
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 20:01:15 -0800 (PST)
In-Reply-To: <20141125.221900.653470310152197801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 22:19 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 25 Nov 2014 17:43:05 -0800
> 
> > I believe I finally have an idea why we had various + 15 in skb
> > allocations in TCP stack !
> 
> It was so that you could do one level of tunneling with "for
> free".  Or that is my recollection.
> 
> Those + 15 existed way before any of these padto() calls even
> existed.


Well, tunneling is added in front of the packet. Thats why we use
MAX_TCP_HEADER.

The +15 is in fact because TCP stack wanted to make sure the eventual
padding (needing tailroom, not headroom) was possible...

Note that ack packets never used the +15, but other packets did.
