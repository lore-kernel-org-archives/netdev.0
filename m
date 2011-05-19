From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow hash
Date: Thu, 19 May 2011 12:56:45 -0700
Message-ID: <BANLkTinZOEz7Bhc+UgcWkrGb-rtCJ-kFvg@mail.gmail.com>
References: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
	<1305821795.3028.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:58183 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934153Ab1EST4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:56:48 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p4JJulsl006154
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 12:56:48 -0700
Received: from pvh18 (pvh18.prod.google.com [10.241.210.210])
	by wpaz33.hot.corp.google.com with ESMTP id p4JJukYh018013
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 12:56:46 -0700
Received: by pvh18 with SMTP id 18so1826680pvh.31
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 12:56:46 -0700 (PDT)
In-Reply-To: <1305821795.3028.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

Thanks for comments.

> For sure it helps if this machine is the final host for these packets.
>
I would hope it helps routers too, assuming RPS already helps non
encapsulated traffic in a router.

> If I am a firewall or router [and not looking into GRE packets], maybe I
> dont want to spread all packets received on a tunnel to several cpus and
> reorder them when forwarded.
>
Do know a specific use case where this patch would be a bad thing?  I
don't believe there's any special ooo constraints on the packets in a
tunnel, flow ordering should still be maintained.

> 3) table could contains 'pointers' to decoding function, that would
> recompute a new rxhash function.
>
This could be done as a function in the protocol switch table, so that
all the protocol specific code could be moved out of dev.c.  I thought
about that several times but haven't convinced myself it's worth it;
even with the code to handle tunneling the get_hash function is still
pretty elegant (I believe ipip support is just two more lines by the
way).
