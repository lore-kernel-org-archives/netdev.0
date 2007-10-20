From: Krzysztof Oledzki <ole@ans.pl>
Subject: ISNs and 2.6.22, Was: Re: haproxy & linux firewall (netfilter)
Date: Sat, 20 Oct 2007 19:08:52 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710201853070.19637@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0710192358340.17074@bizon.gios.gov.pl>
 <20071020055604.GA1371@1wt.eu> <Pine.LNX.4.64.0710201422220.17074@bizon.gios.gov.pl>
 <20071020133101.GB3490@1wt.eu> <Pine.LNX.4.64.0710201544290.17074@bizon.gios.gov.pl>
 <20071020150035.GA12878@1wt.eu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1748699901-1192899739=:19637"
Cc: haproxy@formilux.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:36434 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbXJTRJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2007 13:09:01 -0400
In-Reply-To: <20071020150035.GA12878@1wt.eu>
Content-ID: <Pine.LNX.4.64.0710201903250.19637@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1748699901-1192899739=:19637
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0710201903251.19637@bizon.gios.gov.pl>



On Sat, 20 Oct 2007, Willy Tarreau wrote:
<CUT>

>>> What is very strange is that linux uses random increments, so your ISNs
>>> should not wrap in a matter of a few seconds.
>>
>> Good point. I need to investigate this.
>
> netcat is very convenient for such tests. It's easy to bind it to a
> source port for consecutive tests while you run tcpdump in the background=
 :
>
>  $ echo bla | nc -p 1234 192.168.1.2 80
>  $ echo bla | nc -p 1234 192.168.1.2 80
>
> Also, please try this with tcp_timestamps enabled and disabled to see if =
it
> changes anything.

Interesting... :|

2.6.20:
18:52:33.558379 IP 192.168.0.33.3333 > 212.77.100.101.80: S 3708509816:3708=
509816(0) win 5840 <mss 1460,sackOK,timestamp 1884090256 0,nop,wscale 1>
18:52:33.882129 IP 192.168.0.33.3333 > 212.77.100.101.80: S 3708833567:3708=
833567(0) win 5840 <mss 1460,sackOK,timestamp 1884090580 0,nop,wscale 1>
18:52:34.084000 IP 192.168.0.33.3333 > 212.77.100.101.80: S 3709035437:3709=
035437(0) win 5840 <mss 1460,sackOK,timestamp 1884090782 0,nop,wscale 1>

2.6.21:
18:58:36.074969 IP 192.168.0.66.3333 > 212.77.100.101.80: S 110585153:11058=
5153(0) win 5840 <mss 1460,sackOK,timestamp 112007046 0,nop,wscale 5>
18:58:36.440084 IP 192.168.0.66.3333 > 212.77.100.101.80: S 110950271:11095=
0271(0) win 5840 <mss 1460,sackOK,timestamp 112007412 0,nop,wscale 5>
18:58:36.830141 IP 192.168.0.66.3333 > 212.77.100.101.80: S 111340328:11134=
0328(0) win 5840 <mss 1460,sackOK,timestamp 112007802 0,nop,wscale 5>

2.6.22:
18:59:34.525097 IP 192.168.0.7.3333 > 212.77.100.101.80: S 3303295586:33032=
95586(0) win 5840 <mss 1460,sackOK,timestamp 1111842 0,nop,wscale 6>
18:59:34.942104 IP 192.168.0.7.3333 > 212.77.100.101.80: S 3720303240:37203=
03240(0) win 5840 <mss 1460,sackOK,timestamp 1112259 0,nop,wscale 6>
18:59:35.412229 IP 192.168.0.7.3333 > 212.77.100.101.80: S 4190427367:41904=
27367(0) win 5840 <mss 1460,sackOK,timestamp 1112729 0,nop,wscale 6>

2.6.22+tcp_timestamps=3D0:
19:00:38.285554 IP 192.168.0.7.3333 > 212.77.100.101.80: S 2639244549:26392=
44549(0) win 5840 <mss 1460,nop,nop,sackOK,nop,wscale 6>
19:00:39.448675 IP 192.168.0.7.3333 > 212.77.100.101.80: S 3802363348:38023=
63348(0) win 5840 <mss 1460,nop,nop,sackOK,nop,wscale 6>
19:00:43.003850 IP 192.168.0.7.3333 > 212.77.100.101.80: S 3062574559:30625=
74559(0) win 5840 <mss 1460,nop,nop,sackOK,nop,wscale 6>
19:00:45.950863 IP 192.168.0.7.3333 > 212.77.100.101.80: S 1714619373:17146=
19373(0) win 5840 <mss 1460,nop,nop,sackOK,nop,wscale 6>

So it seems that ISNs are not randomly incremented but rather randomly=20
generated. Adding netdev@vger.kernel.org to the CC list.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1748699901-1192899739=:19637--
