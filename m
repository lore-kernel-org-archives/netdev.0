From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: XFRM / DF Flag / Fragmentation Needed
Date: Wed, 17 Nov 2004 12:36:18 +1100
Message-ID: <E1CUEk6-00036P-00@gondolin.me.apana.org.au>
References: <Pine.GSO.4.56.0411161447340.7679@hurricane.csrv.uidaho.edu>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262153AbUKQBgg@vger.kernel.org>
To: dubu0874@uidaho.edu (Thomas DuBuisson)
In-Reply-To: <Pine.GSO.4.56.0411161447340.7679@hurricane.csrv.uidaho.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas DuBuisson <dubu0874@uidaho.edu> wrote:
>
> After A establishes an SSH connection with C and tries to transfer the
> patches the size of a packet from A destined for C is quickly reaches 1500
> while the MTU
> to A is ~1400.  At this point A sends an ICMP 'Fragmentation Needed'
> packet to its self (see xfrm_output.c xfrm4_tunnel_check_size(...)).  It
> seems this packet is never acted on - it just disappears into the
> loopback interface.  The proper mtu trial/error process never takes
> place.

There is a known problem in xfrm4_tunnel_check_size if your underlying
path MTU is a multiple of 8.  So if your path MTU is 1480, you'll need
to lower it to 1476 before it will work.

You can query the path MTU using "ip r g <remote-gateway>".  If it
is a multiple of 8, you can change it by doing

ip r a <remote-gateway> ... mtu <current-mtu - 4>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
