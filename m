From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix tcpi_segs_in after connection
 establishment
Date: Mon, 07 Mar 2016 15:47:43 -0500 (EST)
Message-ID: <20160307.154743.670423088656600403.davem@davemloft.net>
References: <1457135853-4110588-1-git-send-email-kafai@fb.com>
	<1457138013.2761.12.camel@edumazet-ThinkPad-T530>
	<1457285361.2663.24.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, kernel-team@fb.com,
	rapier@psc.edu, edumazet@google.com, mleitner@redhat.com,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577AbcCGUrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:47:46 -0500
In-Reply-To: <1457285361.2663.24.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 06 Mar 2016 09:29:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> If final packet (ACK) of 3WHS is lost, it appears we do not properly
> account the following incoming segment into tcpi_segs_in
> 
> While we are at it, starts segs_in with one, to count the SYN packet.
> 
> We do not yet count number of SYN we received for a request sock, we
> might add this someday.
> 
> packetdrill script showing proper behavior after fix :
> 
> // Tests tcpi_segs_in when 3rd packet (ACK) of 3WHS is lost
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>    +0 bind(3, ..., ...) = 0
>    +0 listen(3, 1) = 0
> 
>    +0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop>
>    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
> +.020 < P. 1:1001(1000) ack 1 win 32792
> 
>    +0 accept(3, ..., ...) = 4
> 
> +.000 %{ assert tcpi_segs_in == 2, 'tcpi_segs_in=%d' % tcpi_segs_in }%
> 
> Fixes: 2efd055c53c06 ("tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
