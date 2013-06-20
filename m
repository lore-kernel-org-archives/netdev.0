From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 4/4] VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH
Date: Thu, 20 Jun 2013 08:12:13 -0700 (PDT)
Message-ID: <783609149.3265072.1371741133384.JavaMail.root@vmware.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com> <1371720033-19714-5-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>
To: Asias He <asias@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:46576 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965231Ab3FTPUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:20:19 -0400
In-Reply-To: <1371720033-19714-5-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If we mod with VSOCK_HASH_SIZE -1, we get 0, 1, .... 249.  Actually, we
> have vsock_bind_table[0 ... 250] and vsock_connected_table[0 .. 250].
> In this case the last entry will never be used.

If I remember correctly, we did this on purpose.  There's actually a
comment about it:

>   * VSOCK_HASH_SIZE + 1 so that vsock_bind_table[0] through
>   * vsock_bind_table[VSOCK_HASH_SIZE - 1] are for bound sockets and
>   * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash

[250] is for unbound sockets.  If you hash on that, you'll mistakenly
get an unbound socket when looking for a bound one.

It is confusing, so perhaps a better way is just to move unbound into
its own table.

Thanks!
- Andy
