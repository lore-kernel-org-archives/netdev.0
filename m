From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix possible seqlock deadlock
Date: Thu, 14 Nov 2013 13:52:50 -0800
Message-ID: <1384465970.28716.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131114191621.GB9630@redhat.com>
	 <1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131114214402.GA23872@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:55250 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756874Ab3KNVwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:52:54 -0500
Received: by mail-yh0-f48.google.com with SMTP id f10so1379515yha.7
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 13:52:53 -0800 (PST)
In-Reply-To: <20131114214402.GA23872@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 16:44 -0500, Dave Jones wrote:
> On Thu, Nov 14, 2013 at 01:37:54PM -0800, Eric Dumazet wrote:
>  > From: Eric Dumazet <edumazet@google.com>
>  > 
>  > ip4_datagram_connect() being called from process context,
>  > it should use IP_INC_STATS() instead of IP_INC_STATS_BH()
>  > otherwise we can deadlock on 32bit arches, or get corruptions of
>  > SNMP counters.
>  > 
>  > Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")
> 
> whoa, 2007. Any idea why I only just started hitting this ?
> 

lockdep support was added very recently.
