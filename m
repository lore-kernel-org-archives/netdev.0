From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Sun, 15 Dec 2013 10:40:59 -0800
Message-ID: <1387132859.19078.207.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44757 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab3LOSlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 13:41:01 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so4422921pdj.30
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 10:41:00 -0800 (PST)
In-Reply-To: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-15 at 13:10 +0100, Christoph Paasch wrote:
> Currently tcp-metrics only stores per-destination addresses. This brings
> problems, when a host has multiple interfaces (e.g., a smartphone having
> WiFi/3G):
> 
> For example, a host contacting a server over WiFi will store the tcp-metrics
> per destination IP. If then the host contacts the same server over 3G, the 
> same tcp-metrics will be used, although the path-characteristics are completly
> different (e.g., the ssthresh is probably not the same).

ssthresh caching is very problematic anyway.

hystart is way better to probe the actual capacity, as the real network 
conditions change every seconds or so.

> 
> The same holds for the fast-open cookie. The server will generate a cookie
> based on our source-address. So, if we contact the same server with another
> source-IP we should request a new cookie.

Yuchung, what do you think ? I think this should already be handled
gracefully, as client be behind a NAT device using a pool of external IP
addresses ?

Thanks Christoph !
