From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Fri, 15 Apr 2005 13:42:56 -0700
Message-ID: <OF44BA08AD.19E86BB6-ON88256FE4.006FB4B2-88256FE4.0071CB74@us.ibm.com>
References: <20050415004102.GA23462@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050415004102.GA23462@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev-bounce@oss.sgi.com wrote on 04/14/2005 05:41:02 PM:

> On Thu, Apr 14, 2005 at 05:31:38PM -0700, David Stevens wrote:
> >
> > > In fact with your patch we can end up calling 
ip6_flush_pending_frames
> > > twice.  Granted that it is currently harmless but it isn't nice.
> >
> >         I don't see this. My original patch only calls
> > ip6_flush_pending_frames() once, since the original code already only

> You called ip6_flush_pending_frames() when rawv6_push_pending_frames
> returned an error.  However rawv6_push_pending_frames can return an
> error that was in turn returned by ip6_push_pending_frames.

> As you know ip6_push_pending_frames always frees the cork buffer so
> this is tantamount to calling ip6_flush_pending_frames twice.

        I missed that, as you know. :-) You're right, of course. Thanks!

> >         I saw that in the code, but I also saw a 2K single skb when 
the
> > MTU is 1500. A piece I looked at appeared to be allocating space for

        I tracked this down-- that particular test was running over
loopback, with its larger MTU. So, no prob. here that I know of here,
either.

        I've reviewed your patch and looks good to me. I've also
tested it with my test cases for IPV6_CHECKSUM and they work fine.
So, I'm good with your patch.

                                                        +-DLS
