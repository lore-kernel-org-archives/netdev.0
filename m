From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug#251215: kernel-image-2.6.6-1-k7: pppd locks up, cannot be
 killed, during ppp shutdown
Date: Sat, 29 May 2004 12:48:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529124833.5eca66d7.davem@redhat.com>
References: <E1BTLVa-000Ezb-FC@johnnybravo.uk.clara.net>
	<20040528124355.GA2391@gondor.apana.org.au>
	<40B744DC.9956BF50@kepier.clara.net>
	<20040529051736.GA11303@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: debian.bugs@kepier.clara.net, 251215@bugs.debian.org, shemminger@osdl.org,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040529051736.GA11303@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 May 2004 15:17:36 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Why do we need to call free_netdev after unregistering the netdev
> from the drivers at all? What's wrong with calling it from run_todo
> itself?

Because the driver is the only agent which knows when it is safe
to free up the structure.  It may still have some attached memory
to free, for example, ala:

	unregister_netdev(dev);
	kfree(dev->priv);
	free_netdev(dev);

This is common, for example in drivers/net/tg3.c:tg3_remove_one() we
have:

		struct tg3 *tp = netdev_priv(dev);

		unregister_netdev(dev);
		iounmap((void *)tp->regs);
		free_netdev(dev);

See?
