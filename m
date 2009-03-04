From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: invert error code in netlink_set_err()
Date: Wed, 04 Mar 2009 11:13:50 +0100
Message-ID: <49AE545E.8090208@trash.net>
References: <20090303233535.7346.25867.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64832 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbZCDKNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 05:13:53 -0500
In-Reply-To: <20090303233535.7346.25867.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> The callers of netlink_set_err() currently pass a negative value
> as parameter for the error code. However, sk->sk_err wants a
> positive error value. Without this patch, skb_recv_datagram() called
> by netlink_recvmsg() may return a positive value to report an error.
> 
> Another choice to fix this is to change callers to pass a positive
> error value, but this seems a bit inconsistent and error prone
> to me. Indeed, the callers of netlink_set_err() assumed that the
> (usual) negative value for error codes was fine before this patch :).

Amazing how this kept hidden for so long. I could have sworn I've
already seen the notification errors in userspace :)
