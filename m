From: Jinxin Zheng <jinxinzheng@gmail.com>
Subject: Re: ipv4 udplite broken in >=linux-3.0 ?
Date: Fri, 18 Nov 2011 20:35:28 +0800
Message-ID: <CABPbr_=fgB-AKK3H8ryccqA7SUO=ejZiWP7tEKYLh=qNG5r7CQ@mail.gmail.com>
References: <CABPbr_msepemFt4ezGVRk3QS0MU3F47MKimfV4Y+6jqvUrLFeA@mail.gmail.com>
	<20111118120430.GG3317@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gerrit@erg.abdn.ac.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53806 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599Ab1KRMfa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 07:35:30 -0500
In-Reply-To: <20111118120430.GG3317@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2011 at 8:04 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Jinxin Zheng | 2011-11-18 12:09:25 [+0800]:
>
>>I don't know how to debug udplite. Can any one of you give me a tip o=
n
>>how to get more debug info, then I can do further test and provide
>>with it?
>
> net-next works for me:
>
> $ sudo aptitude install netsend
> $ sudo tcpdump -n -ttt -vv -i lo > pcap.trace &
> $ netsend udplite receive &
> $ netsend udplite transmit /etc/fstab 127.0.0.1
>
> $ cat pcap.trace
> 00:00:00.000000 IP (tos 0x0, ttl 64, id 30602, offset 0, flags [DF], =
proto unknown (136), length 40) 127.0.0.1 > 127.0.0.1: =A0udplite 20
> 00:00:00.000074 IP (tos 0x0, ttl 64, id 30603, offset 0, flags [DF], =
proto unknown (136), length 1125) 127.0.0.1 > 127.0.0.1: =A0udplite 110=
5
>
>
> Kernel version? What is the output of strace?
>

The kernel version is 3.0. I compiled it myself on a Gentoo i386.

I do not use Ubuntu or Debian. Cannot get netsend in Gentoo ...

But I did the test using the hello_world application downloaded from
Gerrit's wiki:
http://www.erg.abdn.ac.uk/~gerrit/udp-lite/

It contains a simple 'server' and a 'client' program.
The client sends a "Hello World" to the server, and when the server
receives the message it exits.

$ tcpdump -n -ttt -vv -i lo > pcap.trace &
$ ./server &
$ ./client

$ cat pcap.trace
00:00:00.000000 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto
unknown (136), length 41)
   127.0.0.1 > 127.0.0.1:  ip-proto-136 21

the pcap trace seems ok. The sendto() in the client returns ok. But
the server just cannot return from recv() and echo the message...

I can't see anything suspicious from strace for the server or client ei=
ther...

--=20
Zheng Jinxin
