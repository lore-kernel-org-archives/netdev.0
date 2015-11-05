From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix req->saved_syn race
Date: Thu, 05 Nov 2015 12:36:59 -0800
Message-ID: <1446755819.4184.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36421 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbKEUhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 15:37:01 -0500
Received: by pacdm15 with SMTP id dm15so73160182pac.3
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 12:37:00 -0800 (PST)
In-Reply-To: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-05 at 11:07 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
> ireq->pktopts race"), we need to make sure we do not access
> req->saved_syn unless we own the request sock.
> 
> This fixes races for listeners using TCP_SAVE_SYN option.

>  	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));


> +	if (*own_req)
> +		tcp_move_syn(newtp, req_unhash);
>  
>  	return newsk;

Humpff, req_unhash needs to be 'req', otherwise we will crash for FAST
OPEN connections (for which req_unhash == NULL)

I will send a fix, sorry for this David :(
