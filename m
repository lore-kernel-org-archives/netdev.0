From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a	socket
 attached to the skb
Date: Wed, 01 Oct 2008 17:38:20 +0200
Message-ID: <1222875500.7492.6.camel@este>
References: <20081001142431.4893.48078.stgit@este>
 <20081001142431.4893.69772.stgit@este>
 <20081001.075040.135314845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001.075040.135314845.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 2008-10-01 at 07:50 -0700, David Miller wrote:
> From: KOVACS Krisztian <hidden@sch.bme.hu>
> Date: Wed, 01 Oct 2008 16:24:31 +0200
> 
> > Use the socket cached in the TPROXY target if it's present.
> > 
> > Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> 
> Ok, this starts to get into controversial territory.
> :-)
> 
> At the very least I think:
> 
> 1) We should do this unconditionally, and even put
>    a "unlikely" there in the test.
> 
> 2) Actually, the whole operation belongs in a generic
>    net/sock.h helper function, and this includes the
>    leading if() test.

The problem is that if you include the if() test then you have to
include the lookup call as well and that's different for TCP/UDP.

Of course we could create a generic helper that then calls the
appropriate lookup function but that's also an unnecessary extra branch,
isn't it?

-- 
KOVACS Krisztian

