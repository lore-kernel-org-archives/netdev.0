From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_make_synack() minor changes
Date: Wed, 26 Mar 2014 12:08:47 -0700
Message-ID: <1395860927.12610.226.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395853039.12610.217.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140326.142551.19958322633174107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:63874 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727AbaCZTIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:08:49 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so2262432pdj.31
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 12:08:49 -0700 (PDT)
In-Reply-To: <20140326.142551.19958322633174107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-26 at 14:25 -0400, David Miller wrote:
> Do you know where this "+ 15" comes from? :-)
> 
> It is a kind of Linux networking trivia question.

My random guess would be that it is related to a copy/paste
thing, as some tx paths used to allocate skb with a very precise byte
count, and they used HH_DATA_ALIGN().

MAX_TCP_HEADER already includes all needed extra room.

Note tcp_connect() also uses this +15, but not tcp_send_ack() or
tcp_send_active_reset()...
