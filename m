From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Sat, 26 Dec 2009 21:24:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912262122230.23066@melkinpaasi.cs.helsinki.fi>
References: <200912261703.49067.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49363 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbZLZTYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 14:24:13 -0500
In-Reply-To: <200912261703.49067.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:

> Few more dumps. I notice:
> 1)Ack always equal 1
> 2)It is usually first segment of data sent (?)

Is it that you take the tcpdump right from the beginning? Otherwise
tcpdump will get the base sequence numbers from the first segment which 
might be in the middle of the flow already.

> Maybe some value not initialised properly?
> 
> 
> 17:03:50.406118 IP (tos 0x0, ttl 64, id 57958, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.407413 IP (tos 0x0, ttl 64, id 57959, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.408516 IP (tos 0x0, ttl 64, id 57960, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.409553 IP (tos 0x0, ttl 64, id 57961, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.410424 IP (tos 0x0, ttl 64, id 57962, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 
> 
> 
> 17:04:39.801149 IP (tos 0x0, ttl 64, id 19431, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.802538 IP (tos 0x0, ttl 64, id 19432, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.803438 IP (tos 0x0, ttl 64, id 19433, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.804251 IP (tos 0x0, ttl 64, id 19434, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.805050 IP (tos 0x0, ttl 64, id 19435, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 
> 17:06:22.123862 IP (tos 0x0, ttl 64, id 25912, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 17:06:22.124440 IP (tos 0x0, ttl 64, id 25913, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 17:06:22.125600 IP (tos 0x0, ttl 64, id 25914, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> ^C17:06:22.126243 IP (tos 0x0, ttl 64, id 25915, offset 0, flags [DF], proto 
> TCP (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 
> 
> 
> 17:06:43.404279 IP (tos 0x0, ttl 64, id 10279, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.405819 IP (tos 0x0, ttl 64, id 10281, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.406670 IP (tos 0x0, ttl 64, id 10282, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.407821 IP (tos 0x0, ttl 64, id 10283, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 
> 
> 17:07:09.933303 IP (tos 0x0, ttl 64, id 41731, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.934305 IP (tos 0x0, ttl 64, id 41732, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.935076 IP (tos 0x0, ttl 64, id 41733, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.935887 IP (tos 0x0, ttl 64, id 41734, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.937096 IP (tos 0x0, ttl 64, id 41735, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.938083 IP (tos 0x0, ttl 64, id 41736, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 
> 17:09:21.672761 IP (tos 0x0, ttl 64, id 48515, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.673756 IP (tos 0x0, ttl 64, id 48516, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.674574 IP (tos 0x0, ttl 64, id 48517, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.675440 IP (tos 0x0, ttl 64, id 48518, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.676625 IP (tos 0x0, ttl 64, id 48519, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.678963 IP (tos 0x0, ttl 64, id 48521, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 
> 17:11:12.032679 IP (tos 0x0, ttl 64, id 39699, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.033882 IP (tos 0x0, ttl 64, id 39700, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.034835 IP (tos 0x0, ttl 64, id 39701, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.035720 IP (tos 0x0, ttl 64, id 39702, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 

...I'll try to think this more on next week.

-- 
 i.
