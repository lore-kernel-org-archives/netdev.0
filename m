From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 07:50:34 -0700
Message-ID: <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <5716347D.3030808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33063 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbcDSOue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 10:50:34 -0400
Received: by mail-pf0-f169.google.com with SMTP id 184so7633142pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 07:50:34 -0700 (PDT)
In-Reply-To: <5716347D.3030808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 14:37 +0100, Edward Cree wrote:
> Also involved adding a way to run a netfilter hook over a list of packets.
> Rather than attempting to make netfilter know about lists (which would be
> horrendous) we just let it call the regular okfn (in this case
> ip_rcv_finish()) for any packets it steals, and have it give us back a list
> of packets it's synchronously accepted (which normally NF_HOOK would
> automatically call okfn() on, but we want to be able to potentially pass
> the list to a listified version of okfn().)
> 
> There is potential for out-of-order receives if the netfilter hook ends up
> synchronously stealing packets, as they will be processed before any accepts
> earlier in the list.  However, it was already possible for an asynchronous
> accept to cause out-of-order receives, so hopefully I haven't broken
> anything that wasn't broken already.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---

We have hard time to deal with latencies already, and maintaining some
sanity in the stack(s)

This is not going to give us a 10x or even 2x improvement factor, so
what about working on something that would really lower cache line
misses and use pipelines to amortize the costs ?

The main problem in UDP stack today is having to lock the socket because
of the dumb forward allocation problem. Are you really going to provide
a list of skbs up to _one_ UDP socket ?
