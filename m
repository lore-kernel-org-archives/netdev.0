From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Wed, 30 Mar 2005 23:14:22 +1000
Message-ID: <20050330131422.GA10917@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain> <20050330004903.GA3399@gondor.apana.org.au> <1112184572.1089.80.camel@jzny.localdomain> <20050330122321.GA10602@gondor.apana.org.au> <1112187210.1090.140.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112187210.1090.140.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Wed, Mar 30, 2005 at 07:53:30AM -0500, jamal wrote:
>
> I may be influenced by some of the behaviors of rtnetlink users then.
> Typically (I may need to go back and double check), they dont echo back.

That's right.  However, this isn't really an echo.  It's a notification
from the kernel to a particular multicast group.  For example, in the
case of a delete request, the multicast message will presumably contain
full details about the state being deleted.

This is something that may be of interest to the sending process.
 
> > For netlink it is important to use a different socket for receiving
> > multicast messages since otherwise you run the risk of losing unicast
> > messages when it overruns.
> 
> This may be the reason actually now that i think of it. Its not the user
> you are avoiding to echo back to, rather the overloading the user. What

Well the message itself shouldn't overload the user since its size can
be calculated before hand.  If anything is going to overload the netlink
socket it's going to be multicast messages caused by other processes.

Really, if you're going to listen to multicast messages via netlink,
you should do it in a socket where you don't expect to get unicast
responses.
 
> if (n->nlmsg_flags&NLM_F_ECHO)
>   broadcast to all
> else
>   just send to all sans the originator
> 
> sounds reasonable?

Well since I don't think this is an echo request, no :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
