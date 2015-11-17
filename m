From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/9] net: better skb->sender_cpu and
 skb->napi_id cohabitation
Date: Tue, 17 Nov 2015 09:42:34 -0800
Message-ID: <20151117174234.GB89026@ast-mbp.thefacebook.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
 <1447768624-14962-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33031 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbbKQRmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 12:42:37 -0500
Received: by pabfh17 with SMTP id fh17so15709279pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 09:42:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447768624-14962-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2015 at 05:56:56AM -0800, Eric Dumazet wrote:
> skb->sender_cpu and skb->napi_id share a common storage,
> and we had various bugs about this.
> 
> We had to call skb_sender_cpu_clear() in some places to
> not leave a prior skb->napi_id and fool netdev_pick_tx()
> 
> As suggested by Alexei, we could split the space so that
> these errors can not happen.
> 
> 0 value being reserved as the common (not initialized) value,
> let's reserve [1 .. NR_CPUS] range for valid sender_cpu,
> and [NR_CPUS+1 .. ~0U] for valid napi_id.

nice. that's a cleaner and simpler range split.

> This will allow proper busy polling support over tunnels.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Suggested-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

Great series of patches! Looking forward to try them out on rpc workloads.
