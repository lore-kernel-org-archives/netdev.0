From: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Subject: Re: IPSEC in 2.6.25 causes stalled connections
Date: Wed, 18 Jun 2008 02:45:44 +0200
Message-ID: <20080618004544.GA25439@swan.nt.tuwien.ac.at>
References: <20080608010858.GA8877@swan.nt.tuwien.ac.at> <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swan.nt.tuwien.ac.at ([128.131.67.158]:47734 "EHLO
	swan.nt.tuwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276AbYFRApr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 20:45:47 -0400
Content-Disposition: inline
In-Reply-To: <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 03:39:09PM +1000, Herbert Xu wrote:
> Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at> wrote:
> > 
> > Is this a known issue?
> 
> Not to me.  When a connection gets stuck does the SA in question
> still function? For instance, can you send a ping through that
> exact SA?

A concurrently running ping tends to get stuck too. But it is possible
to initiate new connections and ping again through the same SA.  

BTW, now running 2.6.25.7 and the problem still persists.

> Please send us the ip -s x s and ip -s x p output (with your
> serect keys removed/obscured).

I have limited the output to the relevant connection (there are two
additional tunnels configured for another subnet - let me know if this
is also relevant): 

# ip -s x s

src 192.168.69.2 dst 192.168.69.1
        proto esp spi 0xc885bfdd(3364208605) reqid 3(0x00000003) mode tunnel
        replay-window 32 seq 0x00000000 flag  (0x00000000)
        auth hmac(sha1) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (160 bits)
        enc cbc(aes) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (256 bits)
        sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 3056(sec), hard 3600(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          2964393536(bytes), 2063237(packets)
          add 2008-06-18 01:19:47 use 2008-06-18 01:19:48
        stats:
          replay-window 0 replay 0 failed 0
src 192.168.69.1 dst 192.168.69.2
        proto esp spi 0xcaa16773(3399575411) reqid 3(0x00000003) mode tunnel
        replay-window 32 seq 0x00000000 flag  (0x00000000)
        auth hmac(sha1) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (160 bits)
        enc cbc(aes) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (256 bits)
        sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 3600(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          36532224(bytes), 702349(packets)
          add 2008-06-18 01:19:47 use 2008-06-18 01:19:48
        stats:
          replay-window 0 replay 0 failed 0

# ip -s x p

src 192.168.69.2/32 dst 192.168.69.1/32 uid 0
        dir in action allow index 1104 priority 2680 share any flag  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2008-06-18 01:19:47 use 2008-06-18 01:39:16
        tmpl src 192.168.69.2 dst 192.168.69.1
                proto esp spi 0x00000000(0) reqid 3(0x00000003) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 192.168.69.1/32 dst 192.168.69.2/32 uid 0
        dir out action allow index 1097 priority 2680 share any flag  (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2008-06-18 01:19:47 use 2008-06-18 01:39:20
        tmpl src 192.168.69.1 dst 192.168.69.2
                proto esp spi 0x00000000(0) reqid 3(0x00000003) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff
src 192.168.69.2/32 dst 192.168.69.1/32 uid 0
        dir fwd action allow index 1114 priority 2680 share any flag (0x00000000)
        lifetime config:
          limit: soft (INF)(bytes), hard (INF)(bytes)
          limit: soft (INF)(packets), hard (INF)(packets)
          expire add: soft 0(sec), hard 0(sec)
          expire use: soft 0(sec), hard 0(sec)
        lifetime current:
          0(bytes), 0(packets)
          add 2008-06-18 02:09:34 use -
        tmpl src 192.168.69.2 dst 192.168.69.1
                proto esp spi 0x00000000(0) reqid 3(0x00000003) mode tunnel
                level required share any
                enc-mask ffffffff auth-mask ffffffff comp-mask ffffffff

Cheers,

Thomas
