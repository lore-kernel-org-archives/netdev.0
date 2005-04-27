From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Wed, 27 Apr 2005 12:15:11 +1000
Message-ID: <20050427021511.GA19353@gondor.apana.org.au>
References: <20050426111845.GA8968@gondor.apana.org.au> <200504270209.j3R291ml007431@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200504270209.j3R291ml007431@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2005 at 07:09:01PM -0700, Jay Vosburgh wrote:
>
> >dev_ioctl => bond_enslave => bond_check_dev_link => slave_dev->ioctl
> 
> 	Why would it deadlock?  dev_ioctl holds RTNL, bonding grabs
> various bond locks, and the slave device ioctl handler may or may not
> get a lock of its own.  

I get it now.  I had thought that it was calling sys_ioctl but it's
going direct to slave_dev->ioctl which bypasses the rtnl.

So the bond_enslave path is safe but the timer path isn't as you
noted previously.

> >For the amount of work that these timers are doing, the overhead is
> >pretty small.  It is also gentler on the system when the CPU load
> >goes up.
> 
> 	Just so I'm clear: by "the overhead" do you mean the overhead of
> running everything in a work queue, or the overhead of calling out from
> a timer to a work queue for "special occasions"?

I'm referring to running everything out of a work queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
