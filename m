From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 12:15:56 +1100
Message-ID: <20041110011556.GA6853@gondor.apana.org.au>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041109161126.376f755c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 09, 2004 at 04:11:26PM -0800, David S. Miller wrote:
> 
> I totally disagree.  The use of rtnl for all networking configuration
> changes is a virtue of our current setup.

I agree with that.  However, my point is that the RTNL is used for
a lot more than that.
 
> Only the actual implementations know when and where such a
> dependency on device state et al. does not exist, and therefore
> where RTNL holding is not necessary.

You could do that if the RTNL was exclusively used for
protecting net_device.  As it is it protects RTNETLINK
and other things too.

> Therefore I suggest we just implement the fix for this inside of
> the packet scheduler layer itself.  Simply by dropping the RTNL
> semaphore during the module request, and then regrabbing the RTNL
> semaphore and replaying the request from the beginning.

I agree that this will probably the simplest fix.  However,
I'd like to see some evidence that this is actually safe.

For example, rtnetlink_rcv relies on the RTNL to ensure ordering
between requests.  Dropping the RTNL may cause the receive queue
to be processed by another process.

Now as it is I don't think it's a huge problem since we process
requests as soon as they come in.  But if we ever allow requests
to be queued for RTNETLINK this may come back to bite us.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
