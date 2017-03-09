From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC PATCH net] net: Work around lockdep limitation in sockets that use sockets
Date: Thu, 09 Mar 2017 07:51:34 +0000
Message-ID: <21773.1489045894@warthog.procyon.org.uk>
References: <20170308.230625.719131946756053988.davem@davemloft.net> <148881267372.2618.822975702493802450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752157AbdCIHvh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 02:51:37 -0500
In-Reply-To: <20170308.230625.719131946756053988.davem@davemloft.net>
Content-ID: <21772.1489045894.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> I guess this is fine, but I think you can use one of the two "sk_padding"
> bits in struct sock instead of making the structure larger.

It shouldn't make the structure larger since there's a hole in the structure:

		unsigned int		sk_padding : 2,
					sk_no_check_tx : 1,
					sk_no_check_rx : 1,
					sk_userlocks : 4,
					sk_protocol  : 8,
					sk_type      : 16;
	#define SK_PROTOCOL_MAX U8_MAX
		kmemcheck_bitfield_end(flags);

		u16			sk_gso_max_segs;
  ---> 2-byte hole here
		unsigned long	        sk_lingertime;

but I'll quite happily shift it to sk_padding.

Thanks,
David
