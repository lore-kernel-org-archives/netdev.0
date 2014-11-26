From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net-timestamp: make tcp_recvmsg call
 ipv6_recv_error for AF_INET6 socks
Date: Wed, 26 Nov 2014 16:37:47 -0500 (EST)
Message-ID: <20141126.163747.1248122024527332519.davem@davemloft.net>
References: <1417031582-16480-1-git-send-email-willemb@google.com>
	<CA+FuTSdf=3cw7rGhAmPo+hh2qnn_GgPG3Xy8Er259_FxjTur3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbaKZVht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 16:37:49 -0500
In-Reply-To: <CA+FuTSdf=3cw7rGhAmPo+hh2qnn_GgPG3Xy8Er259_FxjTur3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 26 Nov 2014 15:03:01 -0500

> On Wed, Nov 26, 2014 at 2:53 PM, Willem de Bruijn <willemb@google.com> wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
>> If the socket is of family AF_INET6, call ipv6_recv_error instead
>> of ip_recv_error.
>>
>> This change is more complex than a single branch due to the loadable
>> ipv6 module. It reuses a pre-existing indirect function call from
>> ping. The ping code is safe to call, because it is part of the core
>> ipv6 module and always present when AF_INET6 sockets are active.
> 
> I forgot to add:
> 
> Fixes: 4ed2d765 (net-timestamp: TCP timestamping)
> 
>> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.

>> It may also be worthwhile to add WARN_ON_ONCE(sk->family == AF_INET6)
>> to ip_recv_error.

Agreed.  This kind of mistakes do happen, and these routines end up
essentially referencing garbage when it happens.

Thanks again.
