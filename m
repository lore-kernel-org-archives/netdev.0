From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Tue, 05 Apr 2005 22:55:01 -0700
Message-ID: <1112766901.7488.16.camel@mylaptop>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-06 at 12:45 +1000, Herbert Xu wrote:
> Dmitry Yusupov <dmitry_yus@yahoo.com> wrote:
> > 
> > * new event for unicast connections NETLINK_UESTABLISHED.
> 
> Huh? In the patch you're actually sending the notification
> when the socket stops listening to multicast traffic.

it could be that I just screwed up everything as usual and my
application just works as expected for some mythical reasons 8)
but on a serious note, it is sends event from netlink_bind() context for
non-multicast connections only. may be I messed up something, so please
correct me.

> Please document why we need this in greater detail too.

main reason for this is to have clear way to notify netlink user that
new socket created and bound.

> > * netlink alloc_skb() now uses sk_allocation instead of hard-coded
> > GFP_KERNEL
> 
> Why? We never set it to anything else for netlink.

one reason is for consistency with sock interface. sk_allocation is
equal to GFP_KERNEL by default, so nothing changed. but. in some cases
application might require non-blocking kmalloc behavior. one real life
example is networking block device used for swap partition. this way any
GFP_KERENL allocation on recovery path might lead to deadlock condition.
