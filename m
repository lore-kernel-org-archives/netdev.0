From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 17:59:43 +1000
Message-ID: <20060711075943.GB1490@gondor.apana.org.au>
References: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au> <BAY103-F1D9D892CDA10889FCB525B2A80@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35340 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750722AbWGKH7q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 03:59:46 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F1D9D892CDA10889FCB525B2A80@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 08, 2006 at 08:28:32AM +0000, Marco Berizzi wrote:
>
> root@Mimosa:~# ping 10.49.59.23
> PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
> 64 bytes from 10.49.59.23: icmp_seq=1 ttl=247 time=91.9 ms
> 64 bytes from 10.49.59.23: icmp_seq=2 ttl=247 time=49.3 ms
> 64 bytes from 10.49.59.23: icmp_seq=3 ttl=247 time=106 ms
> 64 bytes from 10.49.59.23: icmp_seq=4 ttl=247 time=74.3 ms
> 
> --- 10.49.59.23 ping statistics ---
> 4 packets transmitted, 4 received, 0% packet loss, time 2998ms
> rtt min/avg/max/mdev = 49.316/80.460/106.257/21.241 ms
> root@Mimosa:~# cd /tmp/
> root@Mimosa:/tmp# tcpdump -v -p -n ip host 10.49.59.23 > 
> /tmp/NULL-10.49.59.23 &
> [1] 18981
> root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
> capture size 96 bytes
> 
> root@Mimosa:/tmp# ping 10.49.59.23
> PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
> 
> --- 10.49.59.23 ping statistics ---
> 8 packets transmitted, 0 received, 100% packet loss, time 6999ms
> 
> root@Mimosa:/tmp# fg
> tcpdump -v -p -n ip host 10.49.59.23 >/tmp/NULL-10.49.59.23
> 101 packets captured
> 101 packets received by filter
> 0 packets dropped by kernel

Yes this is really weird.  The only thing I can think of is that it
somehow managed to put some bogus entry into the conntrack table.
What happens if you do

grep 10.49.59.23 /proc/net/ip_conntrack

before and after the tcpdump?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
