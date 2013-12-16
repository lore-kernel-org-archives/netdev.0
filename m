From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Mon, 16 Dec 2013 10:45:13 -0800
Message-ID: <CAK6E8=eeH=6daXoX9Dwe3Nj5LEhKBfL=-2FaLd=Jo7WM-q34qw@mail.gmail.com>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be> <1387132859.19078.207.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43082 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab3LPSp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 13:45:56 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so6963097iec.21
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 10:45:56 -0800 (PST)
In-Reply-To: <1387132859.19078.207.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 15, 2013 at 10:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-12-15 at 13:10 +0100, Christoph Paasch wrote:
>> Currently tcp-metrics only stores per-destination addresses. This brings
>> problems, when a host has multiple interfaces (e.g., a smartphone having
>> WiFi/3G):
>>
>> For example, a host contacting a server over WiFi will store the tcp-metrics
>> per destination IP. If then the host contacts the same server over 3G, the
>> same tcp-metrics will be used, although the path-characteristics are completly
>> different (e.g., the ssthresh is probably not the same).
>
> ssthresh caching is very problematic anyway.
>
> hystart is way better to probe the actual capacity, as the real network
> conditions change every seconds or so.
>
>>
>> The same holds for the fast-open cookie. The server will generate a cookie
>> based on our source-address. So, if we contact the same server with another
>> source-IP we should request a new cookie.
>
> Yuchung, what do you think ? I think this should already be handled
> gracefully, as client be behind a NAT device using a pool of external IP
> addresses ?
Right. Today the Fast Open attempt will fall back to regular TCP
gracefully with the new cookie in SYN-ACK. So if the source ip changed
when the public IP/nat remain the same (common case?), the proposed
change will reduce Fast Open success rate. So it likely has negative
impact only.

This reminds me to add this specific issue in the fast open ietf draft.

>
> Thanks Christoph !
>
>
