From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 09:38:31 -0700
Message-ID: <4AE72207.4030702@hp.com>
References: <200910252158.53921.opurdila@ixiacom.com>	<20091025214357.666350d2@nehalam>	<20091026153656.25be4369@nehalam> <4AE65EDE.8080605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:9281 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbZJ0Qia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 12:38:30 -0400
In-Reply-To: <4AE65EDE.8080605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously Stephen kindly sent me the source and instructions, and attached are 
results from 1.0 GHz Itanium "McKinley" processors using an older gcc, both -O2 
and -O3, -O2 first:

 >>>
 >>>
 >>> $ ./hashtest 10000000 14 | sort -n -k 3 -k 2
 >>> Algorithm             Time       Ratio       Max   StdDev
 >>> string10             0.234133       1.00       612   0.03
 >>> fnv32                0.241471       1.00       689   0.93
 >>> fnv64                0.241964       1.00       680   0.85
 >>> string_hash17        0.269656       1.00       645   0.36
 >>> jhash_string         0.295795       1.00       702   1.00
 >>> crc                  1.609449       1.00       634   0.41
 >>> md5_string           2.479467       1.00       720   0.99
 >>> SuperFastHash        0.273793       1.01       900   2.13
 >>> djb2                 0.265877       1.15       964   9.52
 >>> string_hash31        0.259110       1.21      1039  11.39
 >>> sdbm                 0.369414       2.87      3268  33.77
 >>> elf                  0.372251       3.71      2907  40.71
 >>> pjw                  0.401732       3.71      2907  40.71
 >>> full_name_hash       0.283508      13.09      8796  85.91
 >>> kr_hash              0.220033     499.17    468448 551.55
 >>> fletcher             0.267009     499.17    468448 551.55
 >>> adler32              0.635047     499.17    468448 551.55
 >>> xor                  0.220314     854.94    583189 722.12
 >>> lastchar             0.155236    1637.61   1000000 999.69
 >>
 >>
 >> here then are both, from a 1.0 GHz McKinley system, 64-bit, using an older
 >> gcc
 >>
 >> raj@oslowest:~/hashtest$ ./hashtest 10000000 14 | sort -n -k 3 -k 2
 >> Algorithm             Time       Ratio       Max   StdDev
 >> string_hash17        0.901319       1.00       645   0.36
 >> string10             0.986391       1.00       612   0.03
 >> jhash_string         1.422065       1.00       702   1.00
 >> fnv32                1.705116       1.00       689   0.93
 >> fnv64                1.900326       1.00       680   0.85
 >> crc                  3.651519       1.00       634   0.41
 >> md5_string           14.155621       1.00       720   0.99
 >> SuperFastHash        1.185206       1.01       900   2.13
 >> djb2                 0.977166       1.15       964   9.52
 >> string_hash31        0.989804       1.21      1039  11.39
 >> sdbm                 1.188299       2.87      3268  33.77
 >> pjw                  1.185963       3.71      2907  40.71
 >> elf                  1.257023       3.71      2907  40.71
 >> full_name_hash       1.231514      13.09      8796  85.91
 >> kr_hash              0.890761     499.17    468448 551.55
 >> fletcher             1.080981     499.17    468448 551.55
 >> adler32              4.141714     499.17    468448 551.55
 >> xor                  1.061445     854.94    583189 722.12
 >> lastchar             0.676697    1637.61   1000000 999.69
 >>
 >> raj@oslowest:~/hashtest$ ./hashtest 10000000 8 | sort -n -k 3 -k 2
 >> Algorithm             Time       Ratio       Max   StdDev
 >> string_hash17        0.899988       1.00     39497   1.50
 >> string10             0.985100       1.00     39064   0.01
 >> SuperFastHash        1.141748       1.00     40497   2.17
 >> jhash_string         1.376414       1.00     39669   1.04
 >> fnv32                1.656967       1.00     39895   2.25
 >> fnv64                1.855259       1.00     39215   0.35
 >> crc                  3.615341       1.00     39088   0.07
 >> md5_string           14.113307       1.00     39605   0.98
 >> djb2                 0.972180       1.15     60681  76.16
 >> string_hash31        0.982233       1.21     64950  91.12
 >> sdbm                 1.181952       2.38    129900 232.22
 >> pjw                  1.178994       2.45     99990 237.86
 >> elf                  1.250936       2.45     99990 237.86
 >> kr_hash              0.892633       7.80    468451 515.52
 >> fletcher             1.082932       7.80    468451 515.52
 >> adler32              4.142414       7.80    468451 515.52
 >> full_name_hash       1.175324      13.09    562501 687.24
 >> xor                  1.060091      13.36    583189 694.98
 >> lastchar             0.675610      25.60   1000000 980.27
 >>
 >> raj@oslowest:~/hashtest$ gcc -v
 >> Using built-in specs.
 >> Target: ia64-linux-gnu
 >> Configured with: ../src/configure -v 
--enable-languages=c,c++,fortran,objc,obj-c++,treelang --prefix=/usr 
--enable-shared --with-system-zlib --libexecdir=/usr/lib 
--without-included-gettext --enable-threads=posix --enable-nls 
--program-suffix=-4.1 --enable-__cxa_atexit --enable-clocale=gnu 
--enable-libstdcxx-debug --enable-mpfr --disable-libssp --with-system-libunwind 
--enable-checking=release ia64-linux-gnu
 >> Thread model: posix
 >> gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
 >> raj@oslowest:~/hashtest$
 >>
 >> fnv doesn't seem to do as well there relative to the others as it did in your
 >> tests.
 >
 >
 >
 > You could try -O3 since then gcc may replace the multiply with shift/add
 > or is there something about forcing 32 and 64 bit that makes ia64 suffer.


It seems to speed things up, but the relative ordering remains the same:

oslowest:/home/raj/hashtest# make
cc -O3 -Wall   -c -o hashtest.o hashtest.c
cc -O3 -Wall   -c -o md5.o md5.c
cc -lm  hashtest.o md5.o   -o hashtest
oslowest:/home/raj/hashtest# ./hashtest 10000000 14 | sort -n -k 3 -k 2
Algorithm             Time       Ratio       Max   StdDev
string_hash17        0.893813       1.00       645   0.36
string10             0.965596       1.00       612   0.03
jhash_string         1.387773       1.00       702   1.00
fnv32                1.699041       1.00       689   0.93
fnv64                1.882314       1.00       680   0.85
crc                  3.273676       1.00       634   0.41
md5_string           13.913745       1.00       720   0.99
SuperFastHash        1.135802       1.01       900   2.13
djb2                 0.951571       1.15       964   9.52
string_hash31        0.971081       1.21      1039  11.39
sdbm                 1.168148       2.87      3268  33.77
pjw                  1.159304       3.71      2907  40.71
elf                  1.237662       3.71      2907  40.71
full_name_hash       1.212588      13.09      8796  85.91
kr_hash              0.856584     499.17    468448 551.55
fletcher             1.054516     499.17    468448 551.55
adler32              4.123742     499.17    468448 551.55
xor                  1.031910     854.94    583189 722.12
lastchar             0.648597    1637.61   1000000 999.69
oslowest:/home/raj/hashtest# ./hashtest 10000000 8 | sort -n -k 3 -k 2
Algorithm             Time       Ratio       Max   StdDev
string_hash17        0.884829       1.00     39497   1.50
string10             0.962258       1.00     39064   0.01
SuperFastHash        1.088602       1.00     40497   2.17
jhash_string         1.340878       1.00     39669   1.04
fnv32                1.637096       1.00     39895   2.25
fnv64                1.842330       1.00     39215   0.35
crc                  3.230291       1.00     39088   0.07
md5_string           13.863056       1.00     39605   0.98
djb2                 0.944159       1.15     60681  76.16
string_hash31        0.961978       1.21     64950  91.12
sdbm                 1.159156       2.38    129900 232.22
pjw                  1.154286       2.45     99990 237.86
elf                  1.232842       2.45     99990 237.86
kr_hash              0.856873       7.80    468451 515.52
fletcher             1.055389       7.80    468451 515.52
adler32              4.123254       7.80    468451 515.52
full_name_hash       1.152628      13.09    562501 687.24
xor                  1.033050      13.36    583189 694.98
lastchar             0.647504      25.60   1000000 980.27

