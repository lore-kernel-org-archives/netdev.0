From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sun, 10 Aug 2008 03:56:56 +0200
Message-ID: <200808100356.56432.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <489DC05E.2080901@zytor.com> <20080810002937.GA1461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:40423 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbYHJB47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 21:56:59 -0400
In-Reply-To: <20080810002937.GA1461@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 08 August 2008, Herbert Xu wrote:
> Someone please test this with tcrypt mode=3D200 with and without
> the patch.

Here are the results:


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
*** 2.6.25.13: modprobe tcrypt mode=3D200


testing speed of ecb(aes) encryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 608 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 582 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 702 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1182 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 6421 cycles (819=
2 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1340 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1411 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1747 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 3091 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 18018 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 601 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 628 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 796 cycles (256 =
bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 1468 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 8466 cycles (81=
92 bytes)

testing speed of ecb(aes) decryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 565 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 581 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 702 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1179 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 6409 cycles (819=
2 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1335 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1402 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1738 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 3082 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 17942 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 599 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 627 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 795 cycles (256 =
bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 1469 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 8449 cycles (81=
92 bytes)

testing speed of cbc(aes) encryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 589 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 650 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 920 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1976 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 12588 cycles (81=
92 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1356 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1481 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1985 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 4001 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 25162 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 627 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 714 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 1073 cycles (256=
 bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 2513 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 16704 cycles (8=
192 bytes)

testing speed of cbc(aes) decryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 578 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 634 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 897 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1953 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 12526 cycles (81=
92 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1335 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1459 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1963 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 3978 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 25035 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 603 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 693 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 1053 cycles (256=
 bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 2493 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 16646 cycles (8=
192 bytes)

testing speed of lrw(aes) encryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1367 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 2132 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 5419 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 18399 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 140555 cycles (8=
192 bytes)
test 5 (320 bit key, 16 byte blocks): 1 operation in 2131 cycles (16 by=
tes)
test 6 (320 bit key, 64 byte blocks): 1 operation in 3110 cycles (64 by=
tes)
test 7 (320 bit key, 256 byte blocks): 1 operation in 6958 cycles (256 =
bytes)
test 8 (320 bit key, 1024 byte blocks): 1 operation in 22186 cycles (10=
24 bytes)
test 9 (320 bit key, 8192 byte blocks): 1 operation in 166926 cycles (8=
192 bytes)
test 10 (384 bit key, 16 byte blocks): 1 operation in 1402 cycles (16 b=
ytes)
test 11 (384 bit key, 64 byte blocks): 1 operation in 2283 cycles (64 b=
ytes)
test 12 (384 bit key, 256 byte blocks): 1 operation in 6047 cycles (256=
 bytes)
test 13 (384 bit key, 1024 byte blocks): 1 operation in 20828 cycles (1=
024 bytes)
test 14 (384 bit key, 8192 byte blocks): 1 operation in 160015 cycles (=
8192 bytes)

testing speed of lrw(aes) decryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1314 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 2166 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 5472 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 18667 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 141632 cycles (8=
192 bytes)
test 5 (320 bit key, 16 byte blocks): 1 operation in 2055 cycles (16 by=
tes)
test 6 (320 bit key, 64 byte blocks): 1 operation in 3150 cycles (64 by=
tes)
test 7 (320 bit key, 256 byte blocks): 1 operation in 6983 cycles (256 =
bytes)
test 8 (320 bit key, 1024 byte blocks): 1 operation in 22354 cycles (10=
24 bytes)
test 9 (320 bit key, 8192 byte blocks): 1 operation in 168038 cycles (8=
192 bytes)
test 10 (384 bit key, 16 byte blocks): 1 operation in 1346 cycles (16 b=
ytes)
test 11 (384 bit key, 64 byte blocks): 1 operation in 2425 cycles (64 b=
ytes)
test 12 (384 bit key, 256 byte blocks): 1 operation in 6084 cycles (256=
 bytes)
test 13 (384 bit key, 1024 byte blocks): 1 operation in 21017 cycles (1=
024 bytes)
test 14 (384 bit key, 8192 byte blocks): 1 operation in 161070 cycles (=
8192 bytes)

testing speed of xts(aes) encryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 822 cycles (16 byt=
es)
test 1 (256 bit key, 64 byte blocks): 1 operation in 1391 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 3794 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 13250 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 102299 cycles (8=
192 bytes)
test 5 (384 bit key, 16 byte blocks): 1 operation in 868 cycles (16 byt=
es)
test 6 (384 bit key, 64 byte blocks): 1 operation in 1553 cycles (64 by=
tes)
test 7 (384 bit key, 256 byte blocks): 1 operation in 4328 cycles (256 =
bytes)
test 8 (384 bit key, 1024 byte blocks): 1 operation in 15272 cycles (10=
24 bytes)
test 9 (384 bit key, 8192 byte blocks): 1 operation in 118194 cycles (8=
192 bytes)
test 10 (512 bit key, 16 byte blocks): 1 operation in 875 cycles (16 by=
tes)
test 11 (512 bit key, 64 byte blocks): 1 operation in 1620 cycles (64 b=
ytes)
test 12 (512 bit key, 256 byte blocks): 1 operation in 4440 cycles (256=
 bytes)
test 13 (512 bit key, 1024 byte blocks): 1 operation in 15720 cycles (1=
024 bytes)
test 14 (512 bit key, 8192 byte blocks): 1 operation in 121763 cycles (=
8192 bytes)

testing speed of xts(aes) decryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 804 cycles (16 byt=
es)
test 1 (256 bit key, 64 byte blocks): 1 operation in 1438 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 3826 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 13378 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 103273 cycles (8=
192 bytes)
test 5 (384 bit key, 16 byte blocks): 1 operation in 872 cycles (16 byt=
es)
test 6 (384 bit key, 64 byte blocks): 1 operation in 1561 cycles (64 by=
tes)
test 7 (384 bit key, 256 byte blocks): 1 operation in 4360 cycles (256 =
bytes)
test 8 (384 bit key, 1024 byte blocks): 1 operation in 15400 cycles (10=
24 bytes)
test 9 (384 bit key, 8192 byte blocks): 1 operation in 119199 cycles (8=
192 bytes)
test 10 (512 bit key, 16 byte blocks): 1 operation in 882 cycles (16 by=
tes)
test 11 (512 bit key, 64 byte blocks): 1 operation in 1589 cycles (64 b=
ytes)
test 12 (512 bit key, 256 byte blocks): 1 operation in 4472 cycles (256=
 bytes)
test 13 (512 bit key, 1024 byte blocks): 1 operation in 15848 cycles (1=
024 bytes)
test 14 (512 bit key, 8192 byte blocks): 1 operation in 122767 cycles (=
8192 bytes)


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
*** 2.6.26patched: modprobe tcrypt mode=3D200

testing speed of ecb(aes) encryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 749 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 724 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 844 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1324 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 6594 cycles (819=
2 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1560 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1620 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1956 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 3300 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 18209 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 738 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 764 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 932 cycles (256 =
bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 1604 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 8639 cycles (81=
92 bytes)

testing speed of ecb(aes) decryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 705 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 727 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 847 cycles (256 b=
ytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 1325 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 6600 cycles (819=
2 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1533 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1602 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 1938 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 3282 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 18203 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 743 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 769 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 940 cycles (256 =
bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 1609 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 8636 cycles (81=
92 bytes)

testing speed of cbc(aes) encryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 757 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 819 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 1090 cycles (256 =
bytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 2145 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 12804 cycles (81=
92 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1557 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1681 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 2184 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 4200 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 25400 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 795 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 884 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 1243 cycles (256=
 bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 2684 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 16907 cycles (8=
192 bytes)

testing speed of cbc(aes) decryption
test 0 (128 bit key, 16 byte blocks): 1 operation in 726 cycles (16 byt=
es)
test 1 (128 bit key, 64 byte blocks): 1 operation in 781 cycles (64 byt=
es)
test 2 (128 bit key, 256 byte blocks): 1 operation in 1046 cycles (256 =
bytes)
test 3 (128 bit key, 1024 byte blocks): 1 operation in 2100 cycles (102=
4 bytes)
test 4 (128 bit key, 8192 byte blocks): 1 operation in 12711 cycles (81=
92 bytes)
test 5 (192 bit key, 16 byte blocks): 1 operation in 1539 cycles (16 by=
tes)
test 6 (192 bit key, 64 byte blocks): 1 operation in 1663 cycles (64 by=
tes)
test 7 (192 bit key, 256 byte blocks): 1 operation in 2167 cycles (256 =
bytes)
test 8 (192 bit key, 1024 byte blocks): 1 operation in 4182 cycles (102=
4 bytes)
test 9 (192 bit key, 8192 byte blocks): 1 operation in 25307 cycles (81=
92 bytes)
test 10 (256 bit key, 16 byte blocks): 1 operation in 748 cycles (16 by=
tes)
test 11 (256 bit key, 64 byte blocks): 1 operation in 840 cycles (64 by=
tes)
test 12 (256 bit key, 256 byte blocks): 1 operation in 1202 cycles (256=
 bytes)
test 13 (256 bit key, 1024 byte blocks): 1 operation in 2642 cycles (10=
24 bytes)
test 14 (256 bit key, 8192 byte blocks): 1 operation in 16833 cycles (8=
192 bytes)

testing speed of lrw(aes) encryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1450 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 2613 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 7275 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 25600 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 197439 cycles (8=
192 bytes)
test 5 (320 bit key, 16 byte blocks): 1 operation in 2227 cycles (16 by=
tes)
test 6 (320 bit key, 64 byte blocks): 1 operation in 3750 cycles (64 by=
tes)
test 7 (320 bit key, 256 byte blocks): 1 operation in 8972 cycles (256 =
bytes)
test 8 (320 bit key, 1024 byte blocks): 1 operation in 29972 cycles (10=
24 bytes)
test 9 (320 bit key, 8192 byte blocks): 1 operation in 227490 cycles (8=
192 bytes)
test 10 (384 bit key, 16 byte blocks): 1 operation in 1480 cycles (16 b=
ytes)
test 11 (384 bit key, 64 byte blocks): 1 operation in 2834 cycles (64 b=
ytes)
test 12 (384 bit key, 256 byte blocks): 1 operation in 7841 cycles (256=
 bytes)
test 13 (384 bit key, 1024 byte blocks): 1 operation in 27926 cycles (1=
024 bytes)
test 14 (384 bit key, 8192 byte blocks): 1 operation in 216884 cycles (=
8192 bytes)

testing speed of lrw(aes) decryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1375 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 2581 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 7206 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 25558 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 197416 cycles (8=
192 bytes)
test 5 (320 bit key, 16 byte blocks): 1 operation in 2209 cycles (16 by=
tes)
test 6 (320 bit key, 64 byte blocks): 1 operation in 3769 cycles (64 by=
tes)
test 7 (320 bit key, 256 byte blocks): 1 operation in 8985 cycles (256 =
bytes)
test 8 (320 bit key, 1024 byte blocks): 1 operation in 29959 cycles (10=
24 bytes)
test 9 (320 bit key, 8192 byte blocks): 1 operation in 227532 cycles (8=
192 bytes)
test 10 (384 bit key, 16 byte blocks): 1 operation in 1438 cycles (16 b=
ytes)
test 11 (384 bit key, 64 byte blocks): 1 operation in 2800 cycles (64 b=
ytes)
test 12 (384 bit key, 256 byte blocks): 1 operation in 7852 cycles (256=
 bytes)
test 13 (384 bit key, 1024 byte blocks): 1 operation in 27975 cycles (1=
024 bytes)
test 14 (384 bit key, 8192 byte blocks): 1 operation in 216944 cycles (=
8192 bytes)

testing speed of xts(aes) encryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1031 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 1958 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 5546 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 19898 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 154670 cycles (8=
192 bytes)
test 5 (384 bit key, 16 byte blocks): 1 operation in 1107 cycles (16 by=
tes)
test 6 (384 bit key, 64 byte blocks): 1 operation in 2148 cycles (64 by=
tes)
test 7 (384 bit key, 256 byte blocks): 1 operation in 6192 cycles (256 =
bytes)
test 8 (384 bit key, 1024 byte blocks): 1 operation in 22368 cycles (10=
24 bytes)
test 9 (384 bit key, 8192 byte blocks): 1 operation in 174174 cycles (8=
192 bytes)
test 10 (512 bit key, 16 byte blocks): 1 operation in 1105 cycles (16 b=
ytes)
test 11 (512 bit key, 64 byte blocks): 1 operation in 2147 cycles (64 b=
ytes)
test 12 (512 bit key, 256 byte blocks): 1 operation in 6191 cycles (256=
 bytes)
test 13 (512 bit key, 1024 byte blocks): 1 operation in 22367 cycles (1=
024 bytes)
test 14 (512 bit key, 8192 byte blocks): 1 operation in 174176 cycles (=
8192 bytes)

testing speed of xts(aes) decryption
test 0 (256 bit key, 16 byte blocks): 1 operation in 1045 cycles (16 by=
tes)
test 1 (256 bit key, 64 byte blocks): 1 operation in 1950 cycles (64 by=
tes)
test 2 (256 bit key, 256 byte blocks): 1 operation in 5536 cycles (256 =
bytes)
test 3 (256 bit key, 1024 byte blocks): 1 operation in 19890 cycles (10=
24 bytes)
test 4 (256 bit key, 8192 byte blocks): 1 operation in 154675 cycles (8=
192 bytes)
test 5 (384 bit key, 16 byte blocks): 1 operation in 1119 cycles (16 by=
tes)
test 6 (384 bit key, 64 byte blocks): 1 operation in 2140 cycles (64 by=
tes)
test 7 (384 bit key, 256 byte blocks): 1 operation in 6182 cycles (256 =
bytes)
test 8 (384 bit key, 1024 byte blocks): 1 operation in 22360 cycles (10=
24 bytes)
test 9 (384 bit key, 8192 byte blocks): 1 operation in 174169 cycles (8=
192 bytes)
test 10 (512 bit key, 16 byte blocks): 1 operation in 1118 cycles (16 b=
ytes)
test 11 (512 bit key, 64 byte blocks): 1 operation in 2139 cycles (64 b=
ytes)
test 12 (512 bit key, 256 byte blocks): 1 operation in 6181 cycles (256=
 bytes)
test 13 (512 bit key, 1024 byte blocks): 1 operation in 22359 cycles (1=
024 bytes)
test 14 (512 bit key, 8192 byte blocks): 1 operation in 174157 cycles (=
8192 bytes)

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
