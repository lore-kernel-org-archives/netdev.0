From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Mon, 12 Oct 2009 17:15:35 +0300
Message-ID: <200910121715.35676.denys@visp.net.lb>
References: <200910121143.39924.denys@visp.net.lb> <1255353047.5406.12.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45984 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634AbZJLORg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 10:17:36 -0400
In-Reply-To: <1255353047.5406.12.camel@dogo.mojatatu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How it can be ethernet packets (with PPPoE headers) if i am redirecting from 
ppp interface, not ethernet interface?

PPPoE_146 ~ # tcpdump -ni ppp0 -e -vvv -s 1500 -c 4
tcpdump: WARNING:
tcpdump: listening on ppp0, link-type LINUX_SLL (Linux cooked), capture size 
1500 bytes
17:03:17.015598 Out ethertype IPv4 (0x0800), length 68: (tos 0x0, ttl 111, id 
45623, offset 0, flags [DF], proto TCP (6), length 52)
    68.231.189.241.24800 > 172.16.131.199.1060: Flags [.], cksum 0xd208 
(correct), seq 783840165, ack 1980178761, win 32748, options [nop,nop,sack 1 
{1441:8741}], length 0

PPPoE_146 ~ # tcpdump -ni ifb0 -e -vvv -s 1500 -c 4
tcpdump: WARNING:
tcpdump: WARNING: ifb0: no IPv4 address assigned
tcpdump: listening on ifb0, link-type EN10MB (Ethernet), capture size 1500 
bytes
17:04:01.625547 00:0a:cd:17:5e:08 > 00:0a:cd:14:6b:67, ethertype PPPoE S 
(0x8864), length 70: PPPoE  [ses 0xb] IP (0x0021), length 50: (tos 0x0, ttl 
128, id 51706, offset 0, flags [DF], proto TCP (6), length 48)

Btw i test, if i use userspace pppoe (synchronous) i will get different output 
in tcpdump
PPPoE_146 ~ # tcpdump -ni ifb0 -vvvv
tcpdump: WARNING:
tcpdump: WARNING: ifb0: no IPv4 address assigned
tcpdump: listening on ifb0, link-type EN10MB (Ethernet), capture size 96 bytes
17:15:41.512553 00:28:00:d6:40:00 > ff:03:00:21:45:00, ethertype Unknown 
(0x8006), length 44:
        0x0000:  df49 ac10 8320 cf2e 1c51 0416 0050 ce7b  .I.......Q...P.{
        0x0010:  e177 1caf 491d 5010 ffff 7afe 0000       .w..I.P...z...
17:15:41.520802 00:34:00:d7:40:00 > ff:03:00:21:45:00, ethertype Unknown 
(0x8006), length 112:
        0x0000:  df3c ac10 8320 cf2e 1c51 0416 0050 ce7b  .<.......Q...P.{
        0x0010:  e177 1caf 491d 8010 ffff 686e 0000 0101  .w..I.....hn....
        0x0020:  050a 1caf 4ebd 1caf 545d ff03 0021 4500  ....N...T]...!E.
        0x0030:  0034 00d8 4000 8006 df3b ac10 8320 cf2e  .4..@....;......
        0x0040:  1c51 0416 0050 ce7b e177 1caf 491d 8010  .Q...P.{.w..I...
        0x0050:  ffff                                     ..
17:15:41.528825 00:34:00:d9:40:00 > ff:03:00:21:45:00, ethertype Unknown 
(0x8006), length 56:
        0x0000:  df3a ac10 8320 cf2e 1c51 0416 0050 ce7b  .:.......Q...P.{
        0x0010:  e177 1caf 491d 8010 ffff 5d2e 0000 0101  .w..I.....].....
        0x0020:  050a 1caf 4ebd 1caf 5f9d                 ....N..._.

With PPTP it is as expected, IP packets (like in ppp interface tcpdump).

On Monday 12 October 2009 16:10:47 jamal wrote:
> On Mon, 2009-10-12 at 11:43 +0300, Denys Fedoryschenko wrote:
> > Is it expected that redirecting ppp interface, that supposed to be clean
> > IP traffic is becoming eth encapsulated traffic?
>
> No. Imagine if there were other types of packets non-ip for example,
> what do you do then?
> this feature is as close as you can get when you do switch level
> mirroring or redirection. If you want to edit header before redirect
> etc, use pedit (refer to recent discussion with someone who wanted to
> replicate packets for redundant routing purposes);
>
> cheers,
> jamal


