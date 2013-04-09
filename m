From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modifying the exponential backoff on new connection SYN packets
Date: Tue, 09 Apr 2013 08:12:08 -0700
Message-ID: <1365520328.3887.141.camel@edumazet-glaptop>
References: <5163DA09.5070202@wildgooses.com>
	 <1365515283.3887.124.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Ed W <lists@wildgooses.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39365 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765118Ab3DIPMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:12:12 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so285067pbb.5
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 08:12:11 -0700 (PDT)
In-Reply-To: <1365515283.3887.124.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 06:48 -0700, Eric Dumazet wrote:

> You'll have to change inet_csk_reqsk_queue_prune() in
> net/ipv4/inet_connection_sock.c
> 
> timeo = min(timeout << req->num_timeout, max_rto);
> req->expires = now + timeo; 
> 
> Good luck !

Oh well, this code is for SYNACK retransmits...

For other retransmits, you'll have to take a look in
net/ipv4/tcp_timer.c, around lines 475

icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
