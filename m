From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] dccp: limit sk_filter trim to payload
Date: Wed, 13 Jul 2016 00:53:24 +0200
Message-ID: <578574E4.5050704@iogearbox.net>
References: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com> <1468361937-102786-3-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
	hannes@stressinduktion.org, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46014 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcGLWx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:53:56 -0400
In-Reply-To: <1468361937-102786-3-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2016 12:18 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Dccp verifies packet integrity, including length, at initial rcv in
> dccp_invalid_packet, later pulls headers in dccp_enqueue_skb.
>
> A call to sk_filter in-between can cause __skb_pull to wrap skb->len.
> skb_copy_datagram_msg interprets this as a negative value, so
> (correctly) fails with EFAULT. The negative length is reported in
> ioctl SIOCINQ or possibly in a DCCP_WARN in dccp_close.
>
> Introduce an sk_receive_skb variant that caps how small a filter
> program can trim packets, and call this in dccp with the header
> length. Excessively trimmed packets are now processed normally and
> queued for reception as 0B payloads.
>
> Fixes: 7c657876b63c ("[DCCP]: Initial implementation")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

LGTM, thanks Willem!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
