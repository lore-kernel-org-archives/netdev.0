From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 07:50:17 +0100
Message-ID: <4AE69829.9070207@gmail.com>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com> <4AE68E23.20205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756414AbZJ0Guv@vger.kernel.org>
In-Reply-To: <4AE68E23.20205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> unsigned int fold2(unsigned hash)
> {
> 	return ((unsigned long long)hash * 211) >> 32;
> }
>=20

I tried this reciprocal thing with 511 and 1023 values and got on a PII=
I 550 MHz, gcc-3.3.2 :

# ./hashtest 100000 511=20
jhash_string         0.033123       1.01       234   1.06
fnv32                0.033911       1.02       254   1.38
# ./hashtest 1000000 511
jhash_string         0.331155       1.00      2109   1.10
fnv32                0.359346       1.00      2151   1.65
# ./hashtest 10000000 511
jhash_string         3.383340       1.00     19985   1.03
fnv32                3.849359       1.00     20198   1.53

# ./hashtest 100000 1023
jhash_string         0.033123       1.03       134   1.01
fnv32                0.034260       1.03       142   1.32
# ./hashtest 1000000 1023
jhash_string         0.332329       1.00      1075   1.06
fnv32                0.422035       1.00      1121   1.59
# ./hashtest 10000000 1023
jhash_string         3.417559       1.00     10107   1.01
fnv32                3.747563       1.00     10223   1.35


511 value on 64bit, and 1023 on 32bit arches are nice because
hashsz * sizeof(pointer) <=3D 4096, wasting space for one pointer only.

Conclusion : jhash and 511/1023 hashsize for netdevices,
no divides, only one multiply for the fold.
