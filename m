From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] llc: SOCK_DGRAM interface fixes
Date: Tue, 8 Aug 2006 09:42:10 -0700
Message-ID: <20060808094210.34afd2a5@localhost.localdomain>
References: <20060803092117.5726b4d7@localhost.localdomain>
	<20060808163618.GA1992@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51105 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964998AbWHHQnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 12:43:32 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060808163618.GA1992@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2006 20:36:18 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > This fix goes against the old historical comments about UNIX98 semantics
> > but without this fix SOCK_DGRAM is broken and useless. So either ANK's
> > interpretation was incorect or UNIX98 standard was wrong.
> 
> Just found this reference to me. :-)
> 
> The comment migrated from tcp.c. It is only about connected SOCK_STREAM
> sockets, I do not see how it can make SOCK_DGRAM broken or useless.

The code was in the place where the source information was being copied
from the data portion to the cb portion of the skb. The original code
did the save only for SOCK_STREAM.
The cb portion is needed later to produce the address portion of the
receive handling which is critical with SOCK_DGRAM in LLC.

> That UNIX98 statement allowed to avoid expensive callback to protocol
> specific setup of address in tcp_recvmsg().

So the comment made sense for TCP but not LLC.


-- 
