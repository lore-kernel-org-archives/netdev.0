From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is used
Date: Tue, 26 Oct 2004 20:15:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027001531.GA29973@havoc.gtf.org>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com> <E1CKE5P-0005SP-00@gondolin.me.apana.org.au> <20041020163510.6d13e9c7.davem@davemloft.net> <20041026111912.GA18095@gondor.apana.org.au> <20041026235126.GA4733@gondor.apana.org.au> <417EE3BB.6040902@pobox.com> <20041027000724.GA4869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, thomas.spatzier@de.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041027000724.GA4869@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 10:07:24AM +1000, Herbert Xu wrote:
> On Tue, Oct 26, 2004 at 07:54:35PM -0400, Jeff Garzik wrote:
> > Herbert Xu wrote:
> > >+static int __ethtool_set_sg(struct net_device *dev, u32 data)
> > >+{
> > >+	int err;
> > >+
> > >+	if (!data && dev->ethtool_ops->set_tso) {
> > >+		err = dev->ethtool_ops->set_tso(dev, 0);
> > >+		if (err)
> > >+			return err;
> > >+	}
> > >+
> > >+	return dev->ethtool_ops->set_sg(dev, data);
> > >+}
> > 
> > you want to disable tx-csum also
> 
> IMHO it is valid to disable SG without disabling checksums, no?

It's useless:  The packet header is always in a separate memory
location from the packet data, when using zerocopy sendfile(2).

When not using zerocopy sendfile, you are copying the data _anyway_.

	Jeff
