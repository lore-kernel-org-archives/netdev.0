From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become
 free. Usage count = 1
Date: Thu, 17 Jun 2004 10:10:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617101016.44512cb1.davem@redhat.com>
References: <20040614015013.GA11048@gondor.apana.org.au>
	<20040613210725.70dbd016.davem@redhat.com>
	<20040614042216.GA28669@gondor.apana.org.au>
	<20040614102858.GA12343@gondor.apana.org.au>
	<20040614124402.GA28519@gondor.apana.org.au>
	<20040616193731.GB29781@ms2.inr.ac.ru>
	<20040616130950.6aadde3c.davem@redhat.com>
	<20040616203748.GA30675@ms2.inr.ac.ru>
	<20040616134711.499209c9.davem@redhat.com>
	<20040617081722.GA8559@gondor.apana.org.au>
	<20040617083303.GA8810@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, schwab@suse.de, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040617083303.GA8810@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Herbert, you still don't understand what the synchronize_kernel() is
for.

It is to make sure that anyone (other cpus using the dst) who "saw"
the old dst->dev is done doing whatever they were doing _BEFORE_
we put the device reference.

The best we could do is accumulate devices to be put onto
some kind of list, then at the end of dst_ifdown() do one
synchronize_kernel() then walk the list putting all the
devices.
