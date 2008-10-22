From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Wed, 22 Oct 2008 00:12:17 -0200
Message-ID: <48fe8c06.4719360a.3996.04a9@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
	<alpine.LFD.2.00.0810082154420.3237@apollo>
	<48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
	<Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
	<48f9251b.1626360a.6574.61ec@mx.google.com>
	<Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:26949 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbYJVCM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:12:26 -0400
Received: by yx-out-2324.google.com with SMTP id 8so498728yxm.1
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 19:12:25 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2008 00:48:16 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Try running vmstat 1 > somelog.file to see if there's something=20
> particularly interesting behavior during the stall.

	Here it is. I used nmap more or less in the middle of this log.
The stall happened just on my client machine (stalled sudo) so there's =
only one=20
log ok? Thanks.

procs -----------memory---------- ---swap-- -----io---- -system-- ----c=
pu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy=
 id wa
 1  0  52540  69928  63832 1001580    0    1    17    48   30  119 18  =
1 80  1
 0  0  52540  69844  63832 1001580    0    0     0     0  633  921  0  =
0 100  0
 0  0  52540  69844  63832 1001580    0    0     0   100  621  916  0  =
0 99  0
 1  0  52540  69844  63832 1001580    0    0     0     0  611  893  0  =
0 100  0
 0  0  52540  69716  63832 1001580    0    0     0     0  671  961  0  =
0 100  0
 1  0  52540  69552  63832 1001580    0    0     0     0  813  975  4  =
0 95  0
 0  0  52540  69596  63832 1001580    0    0     0     0  716  947  2  =
0 98  0
 0  0  52540  69596  63832 1001580    0    0     0    36  866 2047  2  =
2 96  0
 0  0  52540  69596  63832 1001580    0    0     0     0  688  964  0  =
0 100  0
 0  0  52540  69596  63832 1001580    0    0     0     0  721 1005  0  =
0 99  0
 0  0  52540  69720  63832 1001580    0    0     0     0  679  958  0  =
0 99  0
 0  0  52540  69720  63832 1001580    0    0     4     0  651  935  0  =
0 99  1
 0  0  52540  69760  63832 1001584    0    0     0    36  990 2105  2  =
2 96  0
 0  0  52540  69720  63832 1001584    0    0     0     0  869 1187  0  =
0 99  0
 0  0  52540  69720  63832 1001584    0    0     0     0  937 1272  0  =
0 100  0
 0  0  52540  69472  63832 1001584    0    0     0     0 1486 1702 17  =
3 79  0
 1  0  52540  68092  63832 1001604    0    0     0     0 2263 2553 36 1=
3 50  0
 0  0  52540  68092  63832 1001604    0    0     0   336 1214 1223  3  =
4 92  0
 3  0  52540  67752  63832 1001604    0    0     0     0 1031 1192  1  =
0 99  0
 0  0  52540  67712  63832 1001604    0    0     0     0  988 1149  1  =
0 99  0
 0  0  52540  67712  63832 1001608    0    0     0     0  989 1127  0  =
0 100  0
 1  0  52540  67712  63832 1001608    0    0     0     0  985 1124  0  =
0 100  0
 0  0  52540  67752  63832 1001608    0    0     0   512 1149 1106  0  =
0 99  0
 2  0  52540  67544  63832 1001608    0    0     0     0 1463 1329  7  =
7 86  0
 2  0  52540  66496  63832 1001612    0    0     0     0 1755 2439 21  =
5 74  0
 0  0  52540  66332  63832 1001620    0    0     0     0 1597 1534 23 1=
2 65  0
 0  0  52540  65992  63836 1001620    0    0    72     0  861 1155  0  =
0 97  2
 0  0  52540  65952  63836 1001688    0    0     0   304  819 1111  1  =
0 98  0
 0  0  52540  65704  63840 1001696    0    0    12     0  847 1194  1  =
0 97  1
 0  0  52540  65704  63840 1001696    0    0     0     0  797 1123  0  =
0 99  0
 2  0  52540  65620  63840 1001696    0    0     0     0  827 1155  1  =
0 99  0
 0  0  52540  65580  63840 1001696    0    0     0     0  747 1033  0  =
0 100  0
 0  0  52540  65496  63840 1001696    0    0     0    84  969 2128  2  =
3 95  0
 0  0  52540  64368  63924 1002608  480    0  1444   148 1593 1471 10  =
5 57 28
 0  0  52540  64480  63924 1002600    0    0     0     0  854 1141  1  =
1 98  0
 1  0  52540  64480  63924 1002604    0    0    12     0 1517 1409 18  =
1 81  0
 0  0  52540  64476  63924 1002624    0    0     0     0 1717 1331 27  =
1 72  0
 0  0  52540  64268  63980 1002600    0    0    56   300 1816 1543 17 1=
4 66  3
 0  0  52540  64240  64004 1002616    0    0    24     0  805 1063  2  =
0 93  4
 0  0  52540  64240  64020 1002628    0    0    16     0  877 1033  1  =
0 96  3
 1  0  52540  64272  64048 1002632    0    0    28     0 1202 2408  3  =
3 90  3
 0  0  52540  64232  64068 1002640    0    0    20     0  961 1121  2  =
0 93  4
 0  0  52540  64232  64076 1002664    0    0     8   288  975 1197  1  =
0 97  2
 1  0  52540  64232  64100 1002668    0    0    24     0  974 1247  1  =
0 93  6
 0  0  52540  64232  64100 1002676    0    0     0     0  961 1177  1  =
0 98  0
 0  0  52540  64108  64300 1002684    0    0   200     0 1157 1337  4  =
0 74 21
 1  0  52540  64108  64328 1002668    0    0    28     0  909 1156  1  =
1 92  6
 0  0  52540  64108  64352 1002688    0    0    24   244  879 1117  1  =
0 94  4
 0  1  52540  64024  64376 1002712    0    0    24     0  932 1171  1  =
0 94  4
 0  0  52540  63984  64396 1002728    0    0    20     0  974 1190  3  =
1 91  4
 1  0  52540  63900  64412 1002732    0    0    16     0  908 1143  1  =
0 96  3
 0  0  52540  63860  64436 1002760    0    0    24     0  857 1105  0  =
0 92  7
 0  0  52540  63608  64444 1002796    0    0     4   380  961 1129  1  =
1 97  1
 0  0  52540  63612  64456 1002824    0    0    12     0  881 1088  2  =
0 95  3

--=20
