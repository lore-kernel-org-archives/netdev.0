From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: deal with listen sockets properly in
 tcp_abort.
Date: Mon, 21 Dec 2015 11:20:53 -0500
Message-ID: <1450714853.8474.124.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450710224-91722-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tom@herbertland.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36562 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbLUQU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 11:20:56 -0500
Received: by mail-qg0-f42.google.com with SMTP id c96so89744717qgd.3
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 08:20:56 -0800 (PST)
In-Reply-To: <1450710224-91722-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-22 at 00:03 +0900, Lorenzo Colitti wrote:
> When closing a listen socket, tcp_abort currently calls
> tcp_done without clearing the request queue. If the socket has a
> child socket that is established but not yet accepted, the child
> socket is then left without a parent, causing a leak.
> 
> Fix this by setting the socket state to TCP_CLOSE and calling
> inet_csk_listen_stop with the socket lock held, like tcp_close
> does.
> 
> Tested using net_test. With this patch, calling SOCK_DESTROY on a
> listen socket that has an established but not yet accepted child
> socket results in the parent and the child being closed, such
> that they no longer appear in sock_diag dumps.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
