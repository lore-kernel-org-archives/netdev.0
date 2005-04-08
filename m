From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Fri, 8 Apr 2005 21:36:55 +1000
Message-ID: <20050408113654.GA26095@gondor.apana.org.au>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au> <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au> <1112823442.16753.68.camel@beastie> <20050406220417.GA4443@gondor.apana.org.au> <1112826385.16753.99.camel@beastie> <20050407213231.GA28738@gondor.apana.org.au> <1112917001.3893.77.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112917001.3893.77.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2005 at 04:36:41PM -0700, Dmitry Yusupov wrote:
> 
> This actually even better since we will guarantee "down" call delivery.
> My only concern is that it is not very generic. Do you know clean way to
> implement it?

How generic do you want this? Do you need this for socket types other
than netlink?

For a one-packet version, we can pre-allocate an skb/page in response to
a setsockopt and store it in sk_send_head/sk_sndmsg_page.

This can then be used at sendmsg time.  Obviously subsequent messages
will have to use alloc_skb until that skb is released.

Alternatively, we can let the socket allocate skb's from an emergency
pool similar to what was discussed in the thread
"Summary of 2005 Kernel Summit Proposed Topics".

Again this could enabled on a setsockopt.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
