From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 11 Jul 2008 16:33:41 +0200
Message-ID: <200807111633.42514.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807101612.59380.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807102314440.14321@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_G92dIcxYtAKsrk2"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:41451 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbYGKOds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 10:33:48 -0400
In-Reply-To: <Pine.LNX.4.64.0807102314440.14321@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_G92dIcxYtAKsrk2
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday, 10. July 2008 23:21:37 Jozsef Kadlecsik wrote:
> You did not mention the type of your driver. Isn't there some changes in
> the driver code between 2.6.23.17 and 2.6.24 which could cause such
> stallings?

It's a 8139too and the "same" hardware works fine at other sites.
I tried the nmap trick mentioned by D=E2niel Fraga with no noticable differ=
ence.

Here's another tcpdump created today, maybe it shows some new/different
information. This time I didn't capture the complete packets to keep it sma=
ll:

15:43:30.580952 IP linux.52292 > mailserver.smtp: S 1353475948:1353475948(0=
) win 5808 <mss 1452,sackOK,timestamp 87884244[|tcp]>
15:43:30.646396 IP mailserver.smtp > linux.52292: S 3868230700:3868230700(0=
) ack 1353475949 win 65535 <mss 1448>
15:43:30.646421 IP linux.52292 > mailserver.smtp: . ack 1 win 5808
15:43:30.711442 IP mailserver.smtp > linux.52292: P 1:79(78) ack 1 win 65535
15:43:30.711457 IP linux.52292 > mailserver.smtp: . ack 79 win 5808
15:43:30.711525 IP linux.52292 > mailserver.smtp: P 1:26(25) ack 79 win 5808
15:43:30.781440 IP mailserver.smtp > linux.52292: P 79:246(167) ack 26 win =
65535
15:43:30.781565 IP linux.52292 > mailserver.smtp: P 26:38(12) ack 246 win 6=
432
15:43:30.844482 IP mailserver.smtp > linux.52292: P 246:264(18) ack 38 win =
65535
15:43:30.844551 IP linux.52292 > mailserver.smtp: P 38:68(30) ack 264 win 6=
432
15:43:30.908539 IP mailserver.smtp > linux.52292: P 264:282(18) ack 68 win =
65535
15:43:30.908580 IP linux.52292 > mailserver.smtp: P 68:82(14) ack 282 win 6=
432
15:43:30.978507 IP mailserver.smtp > linux.52292: P 282:313(31) ack 82 win =
65535
15:43:30.978647 IP linux.52292 > mailserver.smtp: P 82:224(142) ack 313 win=
 6432
15:43:31.056371 IP mailserver.smtp > linux.52292: P 313:542(229) ack 224 wi=
n 65535
15:43:31.056476 IP linux.52292 > mailserver.smtp: . 224:1672(1448) ack 542 =
win 7504
15:43:31.056510 IP linux.52292 > mailserver.smtp: . 1672:3120(1448) ack 542=
 win 7504
15:43:31.056541 IP linux.52292 > mailserver.smtp: P 3120:4320(1200) ack 542=
 win 7504
15:43:31.239389 IP mailserver.smtp > linux.52292: . ack 3120 win 65535
15:43:31.239425 IP linux.52292 > mailserver.smtp: . 4320:5768(1448) ack 542=
 win 7504
15:43:31.239461 IP linux.52292 > mailserver.smtp: . 5768:7216(1448) ack 542=
 win 7504
15:43:31.420453 IP mailserver.smtp > linux.52292: . ack 7216 win 65535
15:43:31.420481 IP linux.52292 > mailserver.smtp: . 7216:8664(1448) ack 542=
 win 7504
15:43:31.420513 IP linux.52292 > mailserver.smtp: . 8664:10112(1448) ack 54=
2 win 7504
15:43:31.420542 IP linux.52292 > mailserver.smtp: . 10112:11560(1448) ack 5=
42 win 7504
15:43:31.601274 IP mailserver.smtp > linux.52292: . ack 10112 win 65535
15:43:31.601300 IP linux.52292 > mailserver.smtp: . 11560:13008(1448) ack 5=
42 win 7504
15:43:31.601331 IP linux.52292 > mailserver.smtp: . 13008:14456(1448) ack 5=
42 win 7504
15:43:31.730384 IP mailserver.smtp > linux.52292: . ack 13008 win 65535
15:43:31.730423 IP linux.52292 > mailserver.smtp: . 14456:15904(1448) ack 5=
42 win 7504
15:43:31.730457 IP linux.52292 > mailserver.smtp: . 15904:17352(1448) ack 5=
42 win 7504
15:43:31.867331 IP mailserver.smtp > linux.52292: . ack 15904 win 65535
15:43:31.867348 IP linux.52292 > mailserver.smtp: . 17352:18800(1448) ack 5=
42 win 7504
15:43:31.867378 IP linux.52292 > mailserver.smtp: . 18800:20248(1448) ack 5=
42 win 7504
15:43:31.867407 IP linux.52292 > mailserver.smtp: P 20248:20704(456) ack 54=
2 win 7504
15:43:32.012416 IP mailserver.smtp > linux.52292: . ack 18800 win 65535
15:43:32.012449 IP linux.52292 > mailserver.smtp: . 20704:22152(1448) ack 5=
42 win 7504
15:43:32.012482 IP linux.52292 > mailserver.smtp: . 22152:23600(1448) ack 5=
42 win 7504
15:43:32.079207 IP mailserver.smtp > linux.52292: . ack 20248 win 65535
15:43:32.079251 IP linux.52292 > mailserver.smtp: . 23600:25048(1448) ack 5=
42 win 7504
15:43:32.224314 IP mailserver.smtp > linux.52292: . ack 23600 win 65535
15:43:32.224348 IP linux.52292 > mailserver.smtp: . 25048:26496(1448) ack 5=
42 win 7504
15:43:32.224382 IP linux.52292 > mailserver.smtp: . 26496:27944(1448) ack 5=
42 win 7504
15:43:32.224411 IP linux.52292 > mailserver.smtp: P 27944:28896(952) ack 54=
2 win 7504
15:43:32.289328 IP mailserver.smtp > linux.52292: . ack 25048 win 65535
15:43:32.289348 IP linux.52292 > mailserver.smtp: . 28896:30344(1448) ack 5=
42 win 7504
15:43:32.415220 IP mailserver.smtp > linux.52292: . ack 27944 win 65535
15:43:32.415242 IP linux.52292 > mailserver.smtp: . 30344:31792(1448) ack 5=
42 win 7504
15:43:32.415284 IP linux.52292 > mailserver.smtp: . 31792:33240(1448) ack 5=
42 win 7504
15:43:32.499213 IP mailserver.smtp > linux.52292: . ack 28896 win 65535
15:43:32.499234 IP linux.52292 > mailserver.smtp: . 33240:34688(1448) ack 5=
42 win 7504
15:43:32.590355 IP mailserver.smtp > linux.52292: . ack 31792 win 65535
15:43:32.590376 IP linux.52292 > mailserver.smtp: . 34688:36136(1448) ack 5=
42 win 7504
15:43:32.590408 IP linux.52292 > mailserver.smtp: P 36136:37088(952) ack 54=
2 win 7504
15:43:32.708128 IP mailserver.smtp > linux.52292: . ack 33240 win 65535
15:43:32.708151 IP linux.52292 > mailserver.smtp: . 37088:38536(1448) ack 5=
42 win 7504
15:43:32.789176 IP mailserver.smtp > linux.52292: . ack 36136 win 65535
15:43:32.789201 IP linux.52292 > mailserver.smtp: . 38536:39984(1448) ack 5=
42 win 7504
15:43:32.789245 IP linux.52292 > mailserver.smtp: . 39984:41432(1448) ack 5=
42 win 7504
15:43:32.915336 IP mailserver.smtp > linux.52292: . ack 38536 win 65535
15:43:32.915364 IP linux.52292 > mailserver.smtp: . 41432:42880(1448) ack 5=
42 win 7504
15:43:32.915395 IP linux.52292 > mailserver.smtp: . 42880:44328(1448) ack 5=
42 win 7504
15:43:33.024198 IP mailserver.smtp > linux.52292: . ack 41432 win 65535
15:43:33.024237 IP linux.52292 > mailserver.smtp: . 44328:45776(1448) ack 5=
42 win 7504
15:43:33.024271 IP linux.52292 > mailserver.smtp: . 45776:47224(1448) ack 5=
42 win 7504
15:43:33.024300 IP linux.52292 > mailserver.smtp: . 47224:48672(1448) ack 5=
42 win 7504
15:43:33.119325 IP mailserver.smtp > linux.52292: . ack 42880 win 65535
15:43:33.119367 IP linux.52292 > mailserver.smtp: P 48672:49376(704) ack 54=
2 win 7504
15:43:33.226202 IP mailserver.smtp > linux.52292: . ack 45776 win 65535
15:43:33.226225 IP linux.52292 > mailserver.smtp: . 49376:50824(1448) ack 5=
42 win 7504
15:43:33.226260 IP linux.52292 > mailserver.smtp: . 50824:52272(1448) ack 5=
42 win 7504
15:43:33.440286 IP mailserver.smtp > linux.52292: . ack 47224 win 65535
15:43:33.440320 IP linux.52292 > mailserver.smtp: . 52272:53720(1448) ack 5=
42 win 7504
15:43:33.440403 IP mailserver.smtp > linux.52292: . ack 50824 win 65535
15:43:33.440420 IP linux.52292 > mailserver.smtp: . 53720:55168(1448) ack 5=
42 win 7504
15:43:33.440453 IP linux.52292 > mailserver.smtp: . 55168:56616(1448) ack 5=
42 win 7504
15:43:33.440477 IP linux.52292 > mailserver.smtp: P 56616:57568(952) ack 54=
2 win 7504
15:43:33.539092 IP mailserver.smtp > linux.52292: . ack 52272 win 65535
15:43:33.539132 IP linux.52292 > mailserver.smtp: . 57568:59016(1448) ack 5=
42 win 7504
15:43:33.621109 IP mailserver.smtp > linux.52292: . ack 55168 win 65535
15:43:33.621153 IP linux.52292 > mailserver.smtp: . 59016:60464(1448) ack 5=
42 win 7504
15:43:33.621201 IP linux.52292 > mailserver.smtp: . 60464:61912(1448) ack 5=
42 win 7504
15:43:33.749209 IP mailserver.smtp > linux.52292: . ack 57568 win 65535
15:43:33.749232 IP linux.52292 > mailserver.smtp: . 61912:63360(1448) ack 5=
42 win 7504
15:43:33.749262 IP linux.52292 > mailserver.smtp: . 63360:64808(1448) ack 5=
42 win 7504
15:43:33.865258 IP mailserver.smtp > linux.52292: . ack 60464 win 65535
15:43:33.865301 IP linux.52292 > mailserver.smtp: . 64808:66256(1448) ack 5=
42 win 7504
15:43:33.865336 IP linux.52292 > mailserver.smtp: . 66256:67704(1448) ack 5=
42 win 7504
15:43:33.959118 IP mailserver.smtp > linux.52292: . ack 61912 win 65535
15:43:33.959158 IP linux.52292 > mailserver.smtp: . 67704:69152(1448) ack 5=
42 win 7504
15:43:34.608440 IP linux.52292 > mailserver.smtp: . 61912:63360(1448) ack 5=
42 win 7504
15:43:34.729935 IP mailserver.smtp > linux.52292: . ack 64808 win 65535
15:43:34.729964 IP linux.52292 > mailserver.smtp: . 69152:70600(1448) ack 5=
42 win 7504

=2E..

15:43:45.324086 IP linux.52292 > mailserver.smtp: . 349832:351280(1448) ack=
 542 win 7504
15:43:45.324117 IP linux.52292 > mailserver.smtp: . 351280:352728(1448) ack=
 542 win 7504
15:43:45.324146 IP linux.52292 > mailserver.smtp: . 352728:354176(1448) ack=
 542 win 7504
15:43:45.445990 IP mailserver.smtp > linux.52292: . ack 303824 win 65535
15:43:45.446010 IP linux.52292 > mailserver.smtp: . 354176:355624(1448) ack=
 542 win 7504
15:43:45.446060 IP linux.52292 > mailserver.smtp: . 355624:357072(1448) ack=
 542 win 7504
15:43:45.569904 IP mailserver.smtp > linux.52292: . ack 306720 win 65535
15:43:45.569928 IP linux.52292 > mailserver.smtp: . 357072:358520(1448) ack=
 542 win 7504
15:43:45.569960 IP linux.52292 > mailserver.smtp: . 358520:359968(1448) ack=
 542 win 7504
15:43:45.569989 IP linux.52292 > mailserver.smtp: . 359968:361416(1448) ack=
 542 win 7504
15:43:45.667941 IP mailserver.smtp > linux.52292: . ack 308168 win 65535
15:43:45.667964 IP linux.52292 > mailserver.smtp: . 361416:362864(1448) ack=
 542 win 7504
15:43:45.752939 IP mailserver.smtp > linux.52292: . ack 311064 win 65535
15:43:45.752958 IP linux.52292 > mailserver.smtp: . 362864:364312(1448) ack=
 542 win 7504
15:43:45.752989 IP linux.52292 > mailserver.smtp: . 364312:365760(1448) ack=
 542 win 7504
15:43:45.753018 IP linux.52292 > mailserver.smtp: . 365760:367208(1448) ack=
 542 win 7504
15:43:45.872905 IP mailserver.smtp > linux.52292: . ack 313960 win 65535
15:43:45.872930 IP linux.52292 > mailserver.smtp: . 367208:368656(1448) ack=
 542 win 7504
15:43:45.872962 IP linux.52292 > mailserver.smtp: . 368656:370104(1448) ack=
 542 win 7504
15:43:45.993879 IP mailserver.smtp > linux.52292: . ack 316856 win 65535
15:43:45.993913 IP linux.52292 > mailserver.smtp: . 370104:371552(1448) ack=
 542 win 7504
15:43:45.993946 IP linux.52292 > mailserver.smtp: . 371552:373000(1448) ack=
 542 win 7504
15:43:45.993975 IP linux.52292 > mailserver.smtp: . 373000:374448(1448) ack=
 542 win 7504
15:43:46.088019 IP mailserver.smtp > linux.52292: . ack 318304 win 65535
15:43:46.088081 IP linux.52292 > mailserver.smtp: . 374448:375896(1448) ack=
 542 win 7504
15:43:46.176935 IP mailserver.smtp > linux.52292: . ack 321200 win 65535
15:43:46.176972 IP linux.52292 > mailserver.smtp: . 375896:377344(1448) ack=
 542 win 7504
15:43:46.177007 IP linux.52292 > mailserver.smtp: . 377344:378792(1448) ack=
 542 win 7504
15:43:46.177035 IP linux.52292 > mailserver.smtp: . 378792:380240(1448) ack=
 542 win 7504
15:43:46.289744 IP mailserver.smtp > linux.52292: . ack 322648 win 65535
15:43:46.289766 IP linux.52292 > mailserver.smtp: . 380240:381688(1448) ack=
 542 win 7504
15:43:46.357708 IP mailserver.smtp > linux.52292: . ack 325544 win 65535
15:43:46.357725 IP linux.52292 > mailserver.smtp: . 381688:383136(1448) ack=
 542 win 7504
15:43:46.357756 IP linux.52292 > mailserver.smtp: . 383136:384584(1448) ack=
 542 win 7504
15:43:46.478932 IP mailserver.smtp > linux.52292: . ack 328440 win 65535
15:43:46.478953 IP linux.52292 > mailserver.smtp: . 384584:386032(1448) ack=
 542 win 7504
15:43:46.478983 IP linux.52292 > mailserver.smtp: . 386032:387480(1448) ack=
 542 win 7504
15:43:46.479011 IP linux.52292 > mailserver.smtp: . 387480:388928(1448) ack=
 542 win 7504
15:43:46.599901 IP mailserver.smtp > linux.52292: . ack 331336 win 65535
15:43:46.599925 IP linux.52292 > mailserver.smtp: . 388928:390376(1448) ack=
 542 win 7504
15:43:46.599957 IP linux.52292 > mailserver.smtp: . 390376:391824(1448) ack=
 542 win 7504
15:43:46.706829 IP mailserver.smtp > linux.52292: . ack 332784 win 65535
15:43:46.706849 IP linux.52292 > mailserver.smtp: . 391824:393272(1448) ack=
 542 win 7504
15:43:46.781694 IP mailserver.smtp > linux.52292: . ack 335680 win 65535
15:43:46.781710 IP linux.52292 > mailserver.smtp: . 393272:394720(1448) ack=
 542 win 7504
15:43:46.781740 IP linux.52292 > mailserver.smtp: . 394720:396168(1448) ack=
 542 win 7504
15:43:46.781768 IP linux.52292 > mailserver.smtp: . 396168:397616(1448) ack=
 542 win 7504
15:43:46.901696 IP mailserver.smtp > linux.52292: . ack 338576 win 65535
15:43:46.901723 IP linux.52292 > mailserver.smtp: . 397616:399064(1448) ack=
 542 win 7504
15:43:46.901756 IP linux.52292 > mailserver.smtp: . 399064:400512(1448) ack=
 542 win 7504
15:43:47.023889 IP mailserver.smtp > linux.52292: . ack 341472 win 65535
15:43:47.023914 IP linux.52292 > mailserver.smtp: . 400512:401960(1448) ack=
 542 win 7504
15:43:47.023946 IP linux.52292 > mailserver.smtp: . 401960:403408(1448) ack=
 542 win 7504
15:43:47.126865 IP mailserver.smtp > linux.52292: . ack 342920 win 65535
15:43:47.126899 IP linux.52292 > mailserver.smtp: . 403408:404856(1448) ack=
 542 win 7504
15:43:47.126933 IP linux.52292 > mailserver.smtp: . 404856:406304(1448) ack=
 542 win 7504
15:43:47.205693 IP mailserver.smtp > linux.52292: . ack 345816 win 65535
15:43:47.205726 IP linux.52292 > mailserver.smtp: . 406304:407752(1448) ack=
 542 win 7504
15:43:47.205760 IP linux.52292 > mailserver.smtp: . 407752:409200(1448) ack=
 542 win 7504
15:43:47.337721 IP mailserver.smtp > linux.52292: . ack 348384 win 65535
15:43:47.337745 IP linux.52292 > mailserver.smtp: . 409200:410648(1448) ack=
 542 win 7504
15:43:47.337778 IP linux.52292 > mailserver.smtp: . 410648:412096(1448) ack=
 542 win 7504
15:43:47.434787 IP mailserver.smtp > linux.52292: . ack 351280 win 65535
15:43:47.434808 IP linux.52292 > mailserver.smtp: . 412096:413544(1448) ack=
 542 win 7504
15:43:47.434840 IP linux.52292 > mailserver.smtp: . 413544:414992(1448) ack=
 542 win 7504
15:43:47.434868 IP linux.52292 > mailserver.smtp: . 414992:416440(1448) ack=
 542 win 7504
15:43:47.547611 IP mailserver.smtp > linux.52292: . ack 352728 win 65535
15:43:47.547635 IP linux.52292 > mailserver.smtp: . 416440:417888(1448) ack=
 542 win 7504
15:43:47.615600 IP mailserver.smtp > linux.52292: . ack 355624 win 65535
15:43:47.615618 IP linux.52292 > mailserver.smtp: . 417888:419336(1448) ack=
 542 win 7504
15:43:47.615650 IP linux.52292 > mailserver.smtp: . 419336:420784(1448) ack=
 542 win 7504
15:43:47.743710 IP mailserver.smtp > linux.52292: . ack 358520 win 65535
15:43:47.743727 IP linux.52292 > mailserver.smtp: . 420784:422232(1448) ack=
 542 win 7504
15:43:47.743759 IP linux.52292 > mailserver.smtp: . 422232:423680(1448) ack=
 542 win 7504
15:43:47.870591 IP mailserver.smtp > linux.52292: . ack 361416 win 65535
15:43:47.870613 IP linux.52292 > mailserver.smtp: . 423680:425128(1448) ack=
 542 win 7504
15:43:47.870644 IP linux.52292 > mailserver.smtp: . 425128:426576(1448) ack=
 542 win 7504
15:43:47.967659 IP mailserver.smtp > linux.52292: . ack 362864 win 65535
15:43:47.967695 IP linux.52292 > mailserver.smtp: . 426576:428024(1448) ack=
 542 win 7504
15:43:48.054611 IP mailserver.smtp > linux.52292: . ack 365760 win 65535
15:43:48.054643 IP linux.52292 > mailserver.smtp: . 428024:429472(1448) ack=
 542 win 7504
15:43:48.054677 IP linux.52292 > mailserver.smtp: . 429472:430920(1448) ack=
 542 win 7504
15:43:48.177804 IP mailserver.smtp > linux.52292: . ack 368656 win 65535
15:43:48.177845 IP linux.52292 > mailserver.smtp: . 430920:432368(1448) ack=
 542 win 7504
15:43:48.177879 IP linux.52292 > mailserver.smtp: . 432368:433816(1448) ack=
 542 win 7504
15:43:48.296768 IP mailserver.smtp > linux.52292: . ack 371552 win 65535
15:43:48.296790 IP linux.52292 > mailserver.smtp: . 433816:435264(1448) ack=
 542 win 7504
15:43:48.296820 IP linux.52292 > mailserver.smtp: . 435264:436712(1448) ack=
 542 win 7504
15:43:48.386685 IP mailserver.smtp > linux.52292: . ack 373000 win 65535
15:43:48.386702 IP linux.52292 > mailserver.smtp: . 436712:438160(1448) ack=
 542 win 7504
15:43:48.478585 IP mailserver.smtp > linux.52292: . ack 375896 win 65535
15:43:48.478605 IP linux.52292 > mailserver.smtp: . 438160:439608(1448) ack=
 542 win 7504
15:43:48.478636 IP linux.52292 > mailserver.smtp: . 439608:441056(1448) ack=
 542 win 7504
15:43:48.597559 IP mailserver.smtp > linux.52292: . ack 377344 win 65535
15:43:48.597581 IP linux.52292 > mailserver.smtp: . 441056:442504(1448) ack=
 542 win 7504
15:43:48.806718 IP mailserver.smtp > linux.52292: . ack 378792 win 65535
15:43:48.806740 IP linux.52292 > mailserver.smtp: . 442504:443952(1448) ack=
 542 win 7504
15:43:52.032437 IP linux.52292 > mailserver.smtp: . 378792:380240(1448) ack=
 542 win 7504
15:43:52.153192 IP mailserver.smtp > linux.52292: . ack 383136 win 65535
15:43:52.153228 IP linux.52292 > mailserver.smtp: . 443952:445400(1448) ack=
 542 win 7504
15:43:52.153262 IP linux.52292 > mailserver.smtp: . 445400:446848(1448) ack=
 542 win 7504
15:43:52.153362 IP mailserver.smtp > linux.52292: . ack 387480 win 65535
15:43:52.153381 IP linux.52292 > mailserver.smtp: . 446848:448296(1448) ack=
 542 win 7504
15:43:59.048438 IP linux.52292 > mailserver.smtp: . 387480:388928(1448) ack=
 542 win 7504
15:43:59.170481 IP mailserver.smtp > linux.52292: . ack 390376 win 65535
15:43:59.170516 IP linux.52292 > mailserver.smtp: . 448296:449744(1448) ack=
 542 win 7504
15:43:59.170551 IP linux.52292 > mailserver.smtp: . 449744:451192(1448) ack=
 542 win 7504
15:43:59.172438 IP mailserver.smtp > linux.52292: . ack 394720 win 65535
15:43:59.172457 IP linux.52292 > mailserver.smtp: . 451192:452640(1448) ack=
 542 win 7504
15:43:59.295693 IP mailserver.smtp > linux.52292: . ack 396168 win 65535
15:44:22.548439 IP linux.52292 > mailserver.smtp: . 396168:397616(1448) ack=
 542 win 7504
15:44:22.669245 IP mailserver.smtp > linux.52292: . ack 399064 win 65535
15:44:22.669266 IP linux.52292 > mailserver.smtp: . 452640:454088(1448) ack=
 542 win 7504
15:44:22.669299 IP linux.52292 > mailserver.smtp: . 454088:455536(1448) ack=
 542 win 7504
15:44:22.669399 IP mailserver.smtp > linux.52292: . ack 404856 win 65535
15:44:22.669427 IP linux.52292 > mailserver.smtp: . 455536:456984(1448) ack=
 542 win 7504
15:45:15.916435 IP linux.52292 > mailserver.smtp: . 404856:406304(1448) ack=
 542 win 7504
15:45:16.127748 IP mailserver.smtp > linux.52292: . ack 406304 win 65535
15:45:16.127773 IP linux.52292 > mailserver.smtp: . 456984:458432(1448) ack=
 542 win 7504
15:45:16.127804 IP linux.52292 > mailserver.smtp: . 458432:459880(1448) ack=
 542 win 7504

=2E..

The full packet flow can be found in the attached dump. Another mail seems
to be transmitted while the first was stalling, but the issue is the same,
the timing information shows no active transfer for over 60s.

Thomas

--Boundary-00=_G92dIcxYtAKsrk2
Content-Type: application/x-bzip2;
  name="smtp.tcpdump.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="smtp.tcpdump.bz2"

QlpoOTFBWSZTWcOwbEMASpX/////////////////////////////////////////////4CLfDYqq
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
HYNiGA==

--Boundary-00=_G92dIcxYtAKsrk2--
