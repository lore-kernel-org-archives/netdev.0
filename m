From: "'tgraf@suug.ch'" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 10:08:12 +0000
Message-ID: <20150318100812.GM17829@casper.infradead.org>
References: <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
 <20150317215638.GA16776@gondor.apana.org.au>
 <20150318095102.GL17829@casper.infradead.org>
 <20150318095516.GA22634@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53740 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbbCRKIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:08:14 -0400
Content-Disposition: inline
In-Reply-To: <20150318095516.GA22634@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/15 at 08:55pm, Herbert Xu wrote:
> On Wed, Mar 18, 2015 at 09:51:02AM +0000, 'tgraf@suug.ch' wrote:
> > 
> > I'm running it like this:
> > for i in $(seq 1 27); do \
> > echo $i: && ./jhash $((2**$i)) | uniq -D | uniq -c \
> 
> uniq -D doesn't do what you think it does:
> 
> $ { echo a; echo b; echo a; } | uniq -D
> $
> 
> So you should use sort | uniq -c

Thanks. The important keyword is "adjacent" here ;-)

With this fixed up I can see what you mean. So if we are
to only do a chain length based decision, the limit would
have to grow together with the table size.

for i in $(seq 1 27); do
echo $i: && ./jhash $((2**$i)) | sort | uniq -D | uniq -c | sort -n -r | head -5;
done

1:
      2 0x0
2:
      3 0x0
3:
      3 0x0
      2 0x2
4:
      2 0xb
      2 0x8
      2 0x4
      2 0x2
      2 0x0
5:
      3 0xe
      3 0x13
      2 0xc
      2 0xa
      2 0x8
6:
      3 0x38
      3 0x37
      3 0x32
      3 0x2f
      3 0x2e
7:
      4 0x37
      3 0x7d
      3 0x79
      3 0x6f
      3 0x69
8:
      6 0xb7
      5 0x79
      4 0xf4
      4 0xe4
      4 0xa3
9:
      5 0xb7
      5 0x9e
      5 0x15b
      5 0x13b
      4 0xdd
10:
      5 0xa4
      5 0x79
      5 0x29e
      5 0x22a
      4 0xf4
11:
      5 0x92
      5 0x4a4
      5 0x479
      5 0x47
      5 0x379
12:
      6 0xf1
      6 0x751
      5 0xf00
      5 0xe26
      5 0xc26
13:
      7 0xf1
      6 0x520
      6 0x1e06
      6 0x1c44
      6 0x11ac
14:
      7 0x3174
      7 0x2f12
      6 0x520
      6 0x3763
      6 0x3615
15:
      7 0xf4
      7 0x7d0b
      7 0x179
      6 0x807
      6 0x69c9
16:
      7 0xf516
      7 0xe659
      7 0xdf00
      7 0x5f5a
      7 0x5cc3
17:
      7 0xe659
      7 0xde5a
      7 0xcaf
      7 0x9cce
      7 0x7fe3
18:
      9 0x17f9b
      8 0x3852d
      7 0x992b
      7 0x5e38
      7 0x3d39e
19:
      8 0x5f22b
      8 0x47d66
      8 0x436ba
      8 0x182aa
      7 0xe095
20:
      8 0xf87dd
      8 0xf464d
      8 0xef51d
      8 0xc08d4
      8 0x91a96
21:
      9 0xa7a90
      9 0x1fc5ad
      8 0xfae2f
      8 0xd4123
      8 0xb5686
22:
      9 0x97b11
      9 0x3fcfa3
      8 0xffa9e
      8 0xfa437
      8 0xef7e6
23:
     10 0x3b3115
      9 0x5cb5ba
      9 0x568fbf
      9 0x54d790
      9 0x4c2393
24:
     10 0x86373a
     10 0x35794f
      9 0xf6d21e
      9 0xde5301
      9 0xb36b9d
