From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 7/7] tcp: make tcp_sendmsg() aware of socket
 backlog
Date: Thu, 28 Apr 2016 22:05:55 -0700
Message-ID: <1461906355.5535.141.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com>
	 <1461899449-8096-8-git-send-email-edumazet@google.com>
	 <5722E663.8080304@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:34537 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcD2FF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 01:05:59 -0400
Received: by mail-yw0-f181.google.com with SMTP id j74so144456176ywg.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 22:05:59 -0700 (PDT)
In-Reply-To: <5722E663.8080304@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 21:43 -0700, Alexei Starovoitov wrote:

> 
> I don't understand the logic completely, but isn't it
> safer to do 'goto wait_for_memory;' here if we happened
> to hit this in the middle of the loop?

Well, the wait_for_memory pushes data, and could early return to user
space with short writes (non blocking IO). This would break things...

After processing backlog, tcp_send_mss() needs to be called again,
and we also need to check sk_err and sk_shutdown. A goto looks fine to
me.

> Also does it make sense to rename __release_sock to
> something like _ _ _sk_flush_backlog, since that's
> what it's doing and not doing any 'release' ?

Well, I guess it could be renamed, but this has been named like that for
decades ? Why changing now, while this patch does not touch it ?
