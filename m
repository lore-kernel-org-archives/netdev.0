From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 00:45:15 +0100
Message-ID: <20050124234515.GA31837@postel.suug.ch>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Coulson <david@davidcoulson.net>,
        "David S. Miller" <davem@davemloft.net>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050124225423.GA15405@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20050124225423.GA15405@gondor.apana.org.au> 2005-01-25 09:54
> On Mon, Jan 24, 2005 at 04:15:10PM +0100, Thomas Graf wrote:
> > 
> > After inspecting your iptables rule set I think it is a general UDP DNAT
> > problem under some circumstances. Some defragmentation weirdness in
> > prerouting might be invovled. It would definitely help to have a dump
> > of a complete ip fragments sequence causing this bug but I can't tell
> > what exactly is the cause just now so yes it might be a good idea to
> > limit the dump to the above subnet and hope the dodgy traffic comes
> > from the same subnet again.
> 
> OK, I think I've found the problem.  It's a totally innocuous bug
> in ip_fragment/ip6_fragment.  When we're in the fast path and use
> the pre-existing frag_list skb's, we forgot to clear ip_summed.

I don't quite understand how this solves the problem. How could
ip_summed be non zero after ip_forward? The earliest possible call
to ip_fragment is in postrouting. Please correct me if I'm wrong.

The bug isn't triggered for every fragment only once in a while so I don't
think it's that simple. 
