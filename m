From: "Damon L. Chesser" <damon@damtek.com>
Subject: Bug#478062: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Thu, 08 May 2008 12:50:44 -0400
Message-ID: <48232F64.6000203@damtek.com>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi> <4821C37A.7040306@damtek.com> <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Reply-To: "Damon L. Chesser" <damon@damtek.com>, 478062@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050704050602070804080109"
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
 Netdev <netdev@vger.kernel.org>,
 David Miller <davem@davemloft.net>
To: Ilpo =?UTF-8?Q?J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.478062.B478062.12102654296541@bugs.debian.org>
In-Reply-To: <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050704050602070804080109
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Ilpo J=E4rvinen wrote:

Snip
>
> Could you next try with tcp_frto set to 1, if my theory proves to be=20
> correct, it too should be "enough" to fix the problem (in this=20
> particular case). Of course you can verify the patch below too if you=20
> want to, the patch should allow cups<->printer to work with tcp_frto =3D=
=20
> 2 too. In case you have problem to apply the patch to the particular=20
> version you're want to try with, just send a note about the version=20
> number to me so I can adapt the patch for you (space etc. formatting=20
> issues may show up because I recently run a code style cleanup on the=20
> tcp code).
>
Ilpo,

I tried the tcp_frto =3D 1 and got the same results as =3D 2.  Attached i=
s=20
the output of the tcpdump for frto=3D1.  I might not get to the patch=20
today as I am feeling a bit slow.=20

Thanks for the work!

--=20
Damon L. Chesser
damon@damtek.com
http://www.linkedin.com/in/dchesser


--------------050704050602070804080109
Content-Type: text/plain;
 name="frtoprob1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="frtoprob1.txt"

1210263858.691448 IP (tos 0x0, ttl 64, id 59590, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 390384065:390384577(512) ack 27168769 win 5840
1210263858.695038 IP (tos 0x0, ttl 100, id 75, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x7df5 (correct), 1:1(0) ack 512 win 1024
1210263858.695231 IP (tos 0x0, ttl 64, id 59591, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 1024:1536(512) ack 1 win 5840
1210263859.394452 IP (tos 0x0, ttl 100, id 76, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x7df5 (correct), 1:1(0) ack 512 win 1024
1210263859.394517 IP (tos 0x0, ttl 64, id 59592, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 512:1024(512) ack 1 win 5840
1210263859.400855 IP (tos 0x0, ttl 100, id 77, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x7bf5 (correct), 1:1(0) ack 1024 win 1024
1210263859.400880 IP (tos 0x0, ttl 64, id 59593, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 1536:2048(512) ack 1 win 5840
1210263860.096485 IP (tos 0x0, ttl 100, id 78, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x7bf5 (correct), 1:1(0) ack 1024 win 1024
1210263979.417094 IP (tos 0x0, ttl 64, id 59594, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 1024:1536(512) ack 1 win 5840
1210263979.421796 IP (tos 0x0, ttl 100, id 82, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x79f5 (correct), 1:1(0) ack 1536 win 1024
1210263979.421850 IP (tos 0x0, ttl 64, id 59595, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 2048:2560(512) ack 1 win 5840
1210263980.121475 IP (tos 0x0, ttl 100, id 83, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x79f5 (correct), 1:1(0) ack 1536 win 1024
1210263980.121525 IP (tos 0x0, ttl 64, id 59596, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 1536:2048(512) ack 1 win 5840
1210263980.127898 IP (tos 0x0, ttl 100, id 84, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x77f5 (correct), 1:1(0) ack 2048 win 1024
1210263980.127915 IP (tos 0x0, ttl 64, id 59597, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 2560:3072(512) ack 1 win 5840
1210263980.822754 IP (tos 0x0, ttl 100, id 85, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x77f5 (correct), 1:1(0) ack 2048 win 1024
1210264100.142724 IP (tos 0x0, ttl 64, id 59598, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 2048:2560(512) ack 1 win 5840
1210264100.148733 IP (tos 0x0, ttl 100, id 92, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x75f5 (correct), 1:1(0) ack 2560 win 1024
1210264100.148766 IP (tos 0x0, ttl 64, id 59599, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 3072:3584(512) ack 1 win 5840
1210264100.843579 IP (tos 0x0, ttl 100, id 93, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x75f5 (correct), 1:1(0) ack 2560 win 1024
1210264100.843629 IP (tos 0x0, ttl 64, id 59600, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 2560:3072(512) ack 1 win 5840
1210264100.850144 IP (tos 0x0, ttl 100, id 94, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x73f5 (correct), 1:1(0) ack 3072 win 1024
1210264100.850161 IP (tos 0x0, ttl 64, id 59601, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 3584:4096(512) ack 1 win 5840
1210264101.549783 IP (tos 0x0, ttl 100, id 95, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x73f5 (correct), 1:1(0) ack 3072 win 1024
1210264220.864362 IP (tos 0x0, ttl 64, id 59602, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 3072:3584(512) ack 1 win 5840
1210264220.870832 IP (tos 0x0, ttl 100, id 99, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x71f5 (correct), 1:1(0) ack 3584 win 1024
1210264220.870874 IP (tos 0x0, ttl 64, id 59603, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 4096:4608(512) ack 1 win 5840
1210264221.570637 IP (tos 0x0, ttl 100, id 100, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x71f5 (correct), 1:1(0) ack 3584 win 1024
1210264221.570684 IP (tos 0x0, ttl 64, id 59604, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 3584:4096(512) ack 1 win 5840
1210264221.577194 IP (tos 0x0, ttl 100, id 101, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6ff5 (correct), 1:1(0) ack 4096 win 1024
1210264221.577211 IP (tos 0x0, ttl 64, id 59605, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 4608:5120(512) ack 1 win 5840
1210264222.271894 IP (tos 0x0, ttl 100, id 102, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6ff5 (correct), 1:1(0) ack 4096 win 1024
1210264341.590019 IP (tos 0x0, ttl 64, id 59606, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 4096:4608(512) ack 1 win 5840
1210264341.593578 IP (tos 0x0, ttl 100, id 106, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6df5 (correct), 1:1(0) ack 4608 win 1024
1210264341.593627 IP (tos 0x0, ttl 64, id 59607, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 5120:5632(512) ack 1 win 5840
1210264342.292717 IP (tos 0x0, ttl 100, id 110, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6df5 (correct), 1:1(0) ack 4608 win 1024
1210264342.292767 IP (tos 0x0, ttl 64, id 59608, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 4608:5120(512) ack 1 win 5840
1210264342.299168 IP (tos 0x0, ttl 100, id 111, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6bf5 (correct), 1:1(0) ack 5120 win 1024
1210264342.299188 IP (tos 0x0, ttl 64, id 59609, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 5632:6144(512) ack 1 win 5840
1210264342.999071 IP (tos 0x0, ttl 100, id 112, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x6bf5 (correct), 1:1(0) ack 5120 win 1024
1210264462.315638 IP (tos 0x0, ttl 64, id 59610, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 5120:5632(512) ack 1 win 5840
1210264462.320063 IP (tos 0x0, ttl 100, id 116, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x69f5 (correct), 1:1(0) ack 5632 win 1024
1210264462.320099 IP (tos 0x0, ttl 64, id 59611, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 6144:6656(512) ack 1 win 5840
1210264463.019784 IP (tos 0x0, ttl 100, id 117, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x69f5 (correct), 1:1(0) ack 5632 win 1024
1210264463.019848 IP (tos 0x0, ttl 64, id 59612, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 5632:6144(512) ack 1 win 5840
1210264463.026210 IP (tos 0x0, ttl 100, id 118, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x67f5 (correct), 1:1(0) ack 6144 win 1024
1210264463.026256 IP (tos 0x0, ttl 64, id 59613, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 6656:7168(512) ack 1 win 5840
1210264463.721025 IP (tos 0x0, ttl 100, id 119, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x67f5 (correct), 1:1(0) ack 6144 win 1024
1210264583.041283 IP (tos 0x0, ttl 64, id 59614, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 6144:6656(512) ack 1 win 5840
1210264583.047127 IP (tos 0x0, ttl 100, id 123, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x65f5 (correct), 1:1(0) ack 6656 win 1024
1210264583.047166 IP (tos 0x0, ttl 64, id 59615, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 7168:7680(512) ack 1 win 5840
1210264583.741856 IP (tos 0x0, ttl 100, id 124, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x65f5 (correct), 1:1(0) ack 6656 win 1024
1210264583.741920 IP (tos 0x0, ttl 64, id 59616, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 6656:7168(512) ack 1 win 5840
1210264583.748296 IP (tos 0x0, ttl 100, id 125, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x63f5 (correct), 1:1(0) ack 7168 win 1024
1210264583.748351 IP (tos 0x0, ttl 64, id 59617, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 7680:8192(512) ack 1 win 5840
1210264584.443149 IP (tos 0x0, ttl 100, id 126, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x63f5 (correct), 1:1(0) ack 7168 win 1024
1210264703.766913 IP (tos 0x0, ttl 64, id 59618, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 7168:7680(512) ack 1 win 5840
1210264703.770428 IP (tos 0x0, ttl 100, id 133, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x61f5 (correct), 1:1(0) ack 7680 win 1024
1210264703.770462 IP (tos 0x0, ttl 64, id 59619, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 8192:8704(512) ack 1 win 5840
1210264704.469029 IP (tos 0x0, ttl 100, id 134, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x61f5 (correct), 1:1(0) ack 7680 win 1024
1210264704.469076 IP (tos 0x0, ttl 64, id 59620, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 7680:8192(512) ack 1 win 5840
1210264704.475326 IP (tos 0x0, ttl 100, id 135, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5ff5 (correct), 1:1(0) ack 8192 win 1024
1210264704.475346 IP (tos 0x0, ttl 64, id 59621, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 8704:9216(512) ack 1 win 5840
1210264705.170173 IP (tos 0x0, ttl 100, id 136, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5ff5 (correct), 1:1(0) ack 8192 win 1024
1210264824.492552 IP (tos 0x0, ttl 64, id 59622, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 8192:8704(512) ack 1 win 5840
1210264824.496167 IP (tos 0x0, ttl 100, id 140, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5df5 (correct), 1:1(0) ack 8704 win 1024
1210264824.496197 IP (tos 0x0, ttl 64, id 59623, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: . 9216:9728(512) ack 1 win 5840
1210264825.191007 IP (tos 0x0, ttl 100, id 141, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5df5 (correct), 1:1(0) ack 8704 win 1024
1210264825.191069 IP (tos 0x0, ttl 64, id 59624, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 8704:9216(512) ack 1 win 5840
1210264825.197574 IP (tos 0x0, ttl 100, id 142, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5bf5 (correct), 1:1(0) ack 9216 win 1024
1210264825.197623 IP (tos 0x0, ttl 64, id 59625, offset 0, flags [DF], proto TCP (6), length 552) 192.168.200.15.33718 > 192.168.200.150.9100: P 9728:10240(512) ack 1 win 5840
1210264825.897222 IP (tos 0x0, ttl 100, id 143, offset 0, flags [none], proto TCP (6), length 40) 192.168.200.150.9100 > 192.168.200.15.33718: ., cksum 0x5bf5 (correct), 1:1(0) ack 9216 win 1024

--------------050704050602070804080109--
