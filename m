From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] rose: limit sk_filter trim to payload
Date: Wed, 13 Jul 2016 00:49:13 +0200
Message-ID: <578573E9.6090807@iogearbox.net>
References: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com> <1468361937-102786-2-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
	hannes@stressinduktion.org, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45515 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbcGLWtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:49:36 -0400
In-Reply-To: <1468361937-102786-2-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2016 12:18 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Sockets can have a filter program attached that drops or trims
> incoming packets based on the filter program return value.
>
> Rose requires data packets to have at least ROSE_MIN_LEN bytes. It
> verifies this on arrival in rose_route_frame and unconditionally pulls
> the bytes in rose_recvmsg. The filter can trim packets to below this
> value in-between, causing pull to fail, leaving the partial header at
> the time of skb_copy_datagram_msg.
>
> Place a lower bound on the size to which sk_filter may trim packets
> by introducing sk_filter_trim_cap and call this for rose packets.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
