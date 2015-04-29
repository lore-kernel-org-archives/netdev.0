From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Wed, 29 Apr 2015 10:17:23 +0200
Message-ID: <55409393.3040003@iogearbox.net>
References: <1430263429-4069-1-git-send-email-edumazet@google.com> <1430263429-4069-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46388 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031451AbbD2IR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 04:17:27 -0400
In-Reply-To: <1430263429-4069-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 01:23 AM, Eric Dumazet wrote:
> Some Congestion Control modules can provide per flow information,
> but current way to get this information is to use netlink.
>
> Like TCP_INFO, let's add TCP_CC_INFO so that applications can
> issue a getsockopt() if they have a socket file descriptor,
> instead of playing complex netlink games.
>
> Sample usage would be :
>
>    union tcp_cc_info info;
>    socklen_t len = sizeof(info);
>
>    if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Presuming other cc algorithms would in future also export
internal information through this interface, would it make
sense to put tcp_cc_info into a container structure so we
don't miss out attr (vegas, dctcp, ...), like:

   struct tcp_cc_exp {
     u32               kind;
     union tcp_cc_info info;
   };

Otherwise looks good:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
