From: Mourad De Clerck <mourad@aquazul.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Sun, 18 Jun 2006 19:25:57 +0200
Message-ID: <44958CA5.20309@aquazul.com>
References: <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com> <448D4236.9050505@aquazul.com> <20060612184941.GA803@electric-eye.fr.zoreil.com> <448DE38D.8070503@aquazul.com> <20060612222947.GC803@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_hell-22056-1150651564-0001-2"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.ypu.org ([80.242.208.21]:741 "EHLO heaven.risen.be")
	by vger.kernel.org with ESMTP id S932266AbWFRR0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2006 13:26:07 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060612222947.GC803@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

Hi,

sorry for the delayed response...

On 13/06/06 00:29, Francois Romieu wrote:
> wget goes faster, right ? Do you have some vmstat 1 output at hand
> for it ?

It does indeed go faster, and it seems a little bit more reliable, but
with big enough transfers it locks up too. See commandline-2.txt and
vmstat-2.txt - it gets through around 600-700MB before locking up. I
also noticed that at 3-4 points during the transfer it seemed to
"pause", and then continue.

> Ok but can you set correctly the link with the command which was told
> to fail in you first mail ? The patch could fix it.

Yes, indeed: doing "ethtool -s eth0 speed 10 autoneg off" switches it to
the slow speed, and keeps it there too (at 10Mb/s).

"ethtool eth0" still reports "Advertised auto-negotiation: Yes" and
"Auto-negotiation: on", which is probably not right. It also reports
"Advertised link modes:  10baseT/Full" only, which is probably correct.

It only actually restarts auto-negotiation when I issue the command
"ethtool -s eth0 autoneg on", at which point the speeds goes back up to
1000Mb/s - the expected behaviour. So it seems ethtool works better than
before wrt auto-negotiation.

> Can you try something like:
> dd if=/dev/zero bs=1024k count=1000 | ssh -c blowfish hell dd of=/tmp/1000m.bin 

Well this transfer (from shuttle -> hell) completed successfully. See
commandline-3.txt and vmstat-3.txt; However I noticed the speed was only
around 7 MB/s and wondered if the link speed was maybe set to 100Mb/s,
so I immediately afterwards did a "wget"-test again, which locked up
after only 5%. The wget test however did confirm the link speed to be
1000Mb/s. See commandline-4.txt and vmstat-4.txt for that last, short test.

> May I assume that the freeze locks everything (keyboard, mouse, led) beyond
> the scp command itself ?

Yes indeed. My (usb) keyboard doesn't respond at all anymore, networking
is completely out, (usb) mouse freezes too. SysRq doesn't seem to help
much either.


-- Mourad

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="commandline-2.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="commandline-2.txt"

shuttle:~# wget http://hell/testfile.bin
--18:39:21--  http://hell/testfile.bin
           => `testfile.bin'
Resolving hell... 10.10.1.1
Connecting to hell|10.10.1.1|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1,073,741,824 (1.0G) [application/octet-stream]

56% [================================>                          ] 602,018,040   27.70M/s    ETA 00:17

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="commandline-3.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="commandline-3.txt"

shuttle:~# dd if=/dev/zero bs=1024k count=1000 | ssh -c blowfish hell dd of=/tmp/1000m.bin
Password:
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 155.971 seconds, 6.7 MB/s
2047951+99 records in
2048000+0 records out
1048576000 bytes (1.0 GB) copied, 140.689 seconds, 7.5 MB/s
shuttle:~#

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="commandline-4.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="commandline-4.txt"

shuttle:~# wget http://hell/testfile.bin
--18:57:26--  http://hell/testfile.bin
           => `testfile.bin'
Resolving hell... 10.10.1.1
Connecting to hell|10.10.1.1|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1,073,741,824 (1.0G) [application/octet-stream]

 5% [>                                    ] 57,266,176    30.30M/s

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="vmstat-2.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmstat-2.txt"

shuttle:~# vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 0  0      0 983108   4672  29140    0    0    33    11  452    64  1  6 92  1
 0  0      0 983108   4672  29140    0    0     0     0  458    18  0  2 98  0
 0  0      0 982556   4688  29588    0    0   464     0  492    65  1  2 90  7
 0  0      0 981316   4692  30720    0    0     0     0 2029   162  0  2 98  0
 0  0      0 951804   4724  59324    0    0     0     0 38927  3128  1 42 57  0
 0  1      0 911380   4764  96528    0    0     4 66940 50360 10405  3 63 33  1
 0  1      0 875916   4796 131716    0    0     0     0 41138  4251  5 69  0 26
 1  1      0 842684   4828 164804    0    0     0     0 38724  4368  3 66  0 31
 1  1      0 807468   4872 199296    0    0     0   204 43170  4254  4 59  9 28
 1  0      0 772748   4908 232772    0    0     4 32516 39246  4071  3 67 22  8
 0  2      0 737656   4940 266256    0    0     0 97720 38868  4612  4 66 30  0
 0  2      0 737532   4940 266256    0    0     0 32768  663    23  0  5  0 95
 0  2      0 738772   4940 266256    0    0     0  6724  551    19  0  3  0 97
 1  1      0 718436   4972 288608    0    0     0   196 26291  2494  3 47  1 49
 0  0      0 676276   5012 329108    0    0     0     0 54791  4380  3 59  2 36
 0  2      0 639944   5048 362376    0    0     4 81856 44893  7185  2 54  9 35
 0  2      0 640564   5048 362376    0    0     0 14268  618    19  0  2  0 98
 0  2      0 641928   5048 362376    0    0     0    24  553    18  0  2  0 98
 0  1      0 608944   5088 396016    0    0     0   128 45004  9135  4 52  6 38
 0  1      0 571868   5124 431544    0    0     0     0 47833  9603  2 59 12 27
 1  1      0 529212   5160 471104    0    0     0 84548 52399  4222  2 61  5 32
 1  3      0 493500   5200 506492    0    0     4 16384 40790  4236  6 74  0 20
 0  3      0 459276   5232 540684    0    0     0  7208 39859  4816  4 68  0 28
 1  5      0 426400   5264 572964    0    0     0   276 37415  4565  6 61  0 33
 0  2      0 400980   5296 598496    0    0     0  2672 30845  4263  4 50  1 45

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="vmstat-3.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmstat-3.txt"

shuttle:~# vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 0  0      0 979352  11984  26012    0    0   123    29  437   118  2  3 92  3
 0  0      0 979352  11984  26012    0    0     0    52  461    26  0  0 100  0
 0  0      0 978540  11988  26316    0    0   308     0  471    53  0  1 95  4
 0  0      0 978416  11988  26316    0    0     0     0  468    26  0  0 100  0
 0  0      0 978416  11988  26328    0    0    12     0  466    25  1  0 98  1
 0  0      0 978416  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0   116  455    25  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  455    15  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  460    24  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  472    27  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  466    46  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  453    17  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  464    24  0  0 100  0
 0  0      0 978416  11988  26328    0    0     0     0  469    27  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  622    79  1  0 99  0
 0  0      0 978168  11988  26328    0    0     0     0 7304   808  3  3 94  0
 0  0      0 978168  11988  26328    0    0     0     0 10653  1181 10  5 85  0
 0  0      0 978168  11988  26328    0    0     0     0 10648  1223 29  7 64  0
 0  0      0 978168  11988  26328    0    0     0     0 10474  1192  0  1 99  0
 0  0      0 978168  11988  26328    0    0     0     0 10348  1172 24  4 73  0
 0  0      0 978168  11988  26328    0    0     0     0 5704   625  9  2 89  0
 1  0      0 978168  11988  26328    0    0     0     0 10385  1136 15  8 77  0
 0  0      0 978168  11988  26328    0    0     0     0 10571  1182 15  4 81  0
 0  0      0 978168  11988  26328    0    0     0     0 10443  1194  8  6 86  0
 0  0      0 978168  11988  26328    0    0     0     0 10623  1205 20  2 78  0
 0  0      0 978168  11988  26328    0    0     0   140 10600  1149 35  9 56  0
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978168  11988  26328    0    0     0     0 10441  1217 21  7 72  0
 0  0      0 978168  11988  26328    0    0     0     0 10424  1162 17  2 81  0
 0  0      0 978168  11988  26328    0    0     0     0 10433  1146  5  1 94  0
 0  0      0 978168  11988  26328    0    0     0     0 10576  1203 39  8 53  0
 0  0      0 978168  11988  26328    0    0     0     0 10627  1217 44  4 52  0
 0  0      0 978168  11988  26328    0    0     0     0 10529  1163 39 13 48  0
 0  0      0 978168  11988  26328    0    0     0     0 10552  1215 18  5 77  0
 1  0      0 978168  11988  26328    0    0     0     0 10459  1146 34  6 60  0
 0  0      0 978168  11988  26328    0    0     0     0 10339  1127  3  6 91  0
 0  0      0 978168  11988  26328    0    0     0     0 6178   673 13  4 83  0
 0  0      0 978168  11988  26328    0    0     0     0 9142  1018  1  4 95  0
 1  0      0 978168  11988  26328    0    0     0     0 6335   697  8  0 92  0
 0  0      0 978168  11988  26328    0    0     0     0 5565   632 21  1 78  0
 0  0      0 978168  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  458    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0 2636   272  7  3 90  0
 0  0      0 978168  11988  26328    0    0     0     0 10321  1159 14  2 84  0
 0  0      0 978168  11988  26328    0    0     0     0 10597  1277  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0 10545  1184 32  8 60  0
 1  0      0 978168  11988  26328    0    0     0     0 9922  1104 19  6 75  0
 0  0      0 978168  11988  26328    0    0     0     0 10417  1177 26 10 64  0
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978168  11988  26328    0    0     0     0 10487  1200 15 17 68  0
 0  0      0 978168  11988  26328    0    0     0     0 10436  1203 30 10 60  0
 0  0      0 978168  11988  26328    0    0     0     0 10413  1191 12  3 85  0
 0  0      0 978168  11988  26328    0    0     0     0 10496  1162 14  8 78  0
 2  0      0 978168  11988  26328    0    0     0     0 10528  1164 20 11 69  0
 0  0      0 978168  11988  26328    0    0     0     0 10586  1185 10  5 85  0
 0  0      0 978168  11988  26328    0    0     0     0 10565  1163  1  4 95  0
 0  0      0 978168  11988  26328    0    0     0     0 10610  1204  7  1 92  0
 0  0      0 978168  11988  26328    0    0     0     0 10550  1170 25  5 70  0
 1  0      0 978168  11988  26328    0    0     0     0 10530  1189 25 15 60  0
 0  0      0 978168  11988  26328    0    0     0     0 8300   948  6  3 91  0
 0  0      0 978168  11988  26328    0    0     0     0 8750  1036  4 15 81  0
 1  0      0 978168  11988  26328    0    0     0     0 10626  1209 29  7 64  0
 1  0      0 978168  11988  26328    0    0     0     0 10496  1170 16 10 74  0
 0  0      0 978168  11988  26328    0    0     0     0 10455  1239 17  6 77  0
 1  0      0 978168  11988  26328    0    0     0     0 9955  1105 10  2 88  0
 0  0      0 978168  11988  26328    0    0     0     0 10361  1214 20  2 78  0
 1  0      0 978168  11988  26328    0    0     0     0 10572  1192 14  3 83  0
 0  0      0 978168  11988  26328    0    0     0     0 10490  1194 27  1 72  0
 0  0      0 978168  11988  26328    0    0     0     0 10558  1308  2  3 95  0
 0  0      0 978168  11988  26328    0    0     0     0 10543  1305  1  2 97  0
 0  0      0 978168  11988  26328    0    0     0     0 9489  1084 10  2 88  0
 1  0      0 978168  11988  26328    0    0     0     0 10428  1228 12  8 80  0
 0  0      0 978168  11988  26328    0    0     0     0 10555  1200 12  3 85  0
 0  0      0 978168  11988  26328    0    0     0     0 10477  1159 37  2 61  0
 0  0      0 978168  11988  26328    0    0     0     0 10474  1175 38  6 56  0
 0  0      0 978168  11988  26328    0    0     0     0 10544  1193 16  5 79  0
 0  0      0 978168  11988  26328    0    0     0     0 10527  1157 18  2 80  0
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978168  11988  26328    0    0     0     0 9445  1068 17  2 81  0
 0  0      0 978168  11988  26328    0    0     0     0 10513  1209 36  4 60  0
 0  0      0 978168  11988  26328    0    0     0     0 10530  1190 27  2 71  0
 0  0      0 978168  11988  26328    0    0     0     0 7100   796 24  2 74  0
 0  0      0 978168  11988  26328    0    0     0     0 9832  1109 15 14 71  0
 0  0      0 978168  11988  26328    0    0     0     0 10455  1267  8  8 84  0
 0  0      0 978168  11988  26328    0    0     0     0 10414  1224  2  3 95  0
 0  0      0 978168  11988  26328    0    0     0     0 10336  1217  4  2 94  0
 0  0      0 978168  11988  26328    0    0     0     0 10428  1176  9  5 86  0
 1  0      0 978168  11988  26328    0    0     0     0 10411  1166 23  2 75  0
 0  0      0 978168  11988  26328    0    0     0     0 7818   863  7  3 90  0
 0  0      0 978168  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    16  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    19  0  0 100  0
 1  0      0 978168  11988  26328    0    0     0     0 2096   211  7  2 91  0
 0  0      0 978168  11988  26328    0    0     0     0 10167  1170  3  4 93  0
 0  0      0 978168  11988  26328    0    0     0     0 10615  1197  3  2 95  0
 0  0      0 978168  11988  26328    0    0     0     0 10404  1218  6  3 91  0
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978168  11988  26328    0    0     0     0 10456  1153 35  8 57  0
 0  0      0 978168  11988  26328    0    0     0     0 10497  1168 15  3 82  0
 0  0      0 978168  11988  26328    0    0     0     0 10103  1146 19  8 73  0
 1  0      0 978168  11988  26328    0    0     0     0 10472  1166 37 12 51  0
 0  0      0 978168  11988  26328    0    0     0     0 10557  1163 44  2 54  0
 1  0      0 978168  11988  26328    0    0     0     0 10531  1186 42  8 50  0
 0  0      0 978168  11988  26328    0    0     0     0 10444  1191 41  9 50  0
 1  0      0 978168  11988  26328    0    0     0     0 10562  1233 44  6 49  0
 0  0      0 978168  11988  26328    0    0     0     0 10571  1205 16  4 80  0
 0  0      0 978168  11988  26328    0    0     0     0 10582  1183 28  4 68  0
 0  0      0 978168  11988  26328    0    0     0     0 10622  1179 22  8 70  0
 0  0      0 978168  11988  26328    0    0     0     0 10615  1183 16  9 75  0
 0  0      0 978168  11988  26328    0    0     0     0 10514  1180 15  4 81  0
 1  0      0 978168  11988  26328    0    0     0     0 10371  1176 22  5 73  0
 0  0      0 978168  11988  26328    0    0     0     0 9910  1088 23  6 71  0
 0  0      0 978168  11988  26328    0    0     0     0 10480  1256  6  5 89  0
 0  0      0 978168  11988  26328    0    0     0     0 10387  1278  0  1 99  0
 1  0      0 978168  11988  26328    0    0     0     0 10572  1203  2  2 96  0
 0  0      0 978168  11988  26328    0    0     0     0 10312  1200  8  0 92  0
 0  0      0 978168  11988  26328    0    0     0     0 10462  1175  1  3 96  0
 0  0      0 978168  11988  26328    0    0     0     0 10402  1225  1  1 98  0
 1  0      0 978168  11988  26328    0    0     0     0 9556  1040 24  4 72  0
 0  0      0 978168  11988  26328    0    0     0     0 10542  1184 10  8 82  0
 0  0      0 978168  11988  26328    0    0     0     0 10575  1188  3  7 90  0
 1  0      0 978168  11988  26328    0    0     0     0 10399  1166 15  0 85  0
 0  0      0 978168  11988  26328    0    0     0     0 9151  1016  2  1 97  0
 0  0      0 978168  11988  26328    0    0     0     0 7011   765 14  0 86  0
 1  0      0 978168  11988  26328    0    0     0     0 10451  1171 22  5 73  0
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978168  11988  26328    0    0     0     0 9359  1037 32  6 62  0
 1  0      0 978168  11988  26328    0    0     0     0 9566  1071 34 11 55  0
 2  0      0 978168  11988  26328    0    0     0     0 9284  1125 40  3 57  0
 0  0      0 978168  11988  26328    0    0     0     0 6798   759 14  3 83  0
 0  0      0 978168  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  453    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  454    15  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    19  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0 6911   794  0  0 100  0
 0  0      0 978168  11988  26328    0    0     0     0 10410  1149 32  2 66  0
 0  0      0 978168  11988  26328    0    0     0     0 10557  1182 47  3 50  0
 0  0      0 978168  11988  26328    0    0     0     0 10220  1164 12  6 82  0
 0  0      0 978292  11988  26328    0    0     0     0 4756   521  5  9 86  0
 0  0      0 978292  11988  26328    0    0     0     0  453    15  0  0 100  0
 0  0      0 978308  11988  26328    0    0     0     0  455    19  0  0 100  0
 0  0      0 978308  11988  26328    0    0     0     0  453    15  0  0 100  0
 0  0      0 978432  11988  26328    0    0     0     0  455    17  0  0 100  0
 0  0      0 978432  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978432  11988  26328    0    0     0     0  454    17  0  0 100  0
 0  0      0 978432  11988  26328    0    0     0     0  457    17  0  0 100  0
 0  0      0 978432  11988  26328    0    0     0     0  453    17  0  0 100  0

shuttle:~#

--=_hell-22056-1150651564-0001-2
Content-Type: text/plain; name="vmstat-4.txt"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmstat-4.txt"

shuttle:~# vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
 1  0      0 978500  12136  26496    0    0    44    12 1629   191  3  2 94  1
 0  0      0 977888  12144  26944    0    0   456     0  476    59  0  0 95  5
 0  0      0 977888  12144  26944    0    0     0     0  456    17  0  0 100  0
 0  0      0 977888  12144  26944    0    0     0     0  463    27  0  0 100  0
 1  0      0 962140  12164  42048    0    0     0     0 20379  1810  2 23 75  0
 1  1      0 919360  12204  81948    0    0     0 54492 52864  9317  2 62 36  0

--=_hell-22056-1150651564-0001-2--
