From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 10:21:47 +0200
Message-ID: <4FE1881B.7030800@profihost.ag>
References: <4FE0EA33.1000309@profihost.ag>  <1340141493.4604.773.camel@edumazet-glaptop>  <4FE17522.5050005@profihost.ag> <1340176940.4604.801.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:37742 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019Ab2FTIVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:21:54 -0400
In-Reply-To: <1340176940.4604.801.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.06.2012 09:22, schrieb Eric Dumazet:
> On Wed, 2012-06-20 at 09:00 +0200, Stefan Priebe - Profihost AG wrote:
>> Am 19.06.2012 23:31, schrieb Eric Dumazet:
>> Before:
>> http://pastebin.com/raw.php?i=1gVraWVc
>>
>> After:
>> http://pastebin.com/raw.php?i=NSh8Y29s
>
> You have a lot of packet losses
But this ONLY happens with tcp_timestamps=0.


> add "tc -s -d qdisc" , "ifconfig -a " and "ethtool -S ethX" outputs for
> both servers

eth2 is the 10Gb device on both systems
server a has kernel 3.5 server b has rhel 6 kernel

Server A:
# tc -s -d qdisc
RTNETLINK answers: Operation not supported
Dump terminated

Server B (eth2 is the 10GB/s device):
# tc -s -d qdisc
qdisc mq 0: dev eth0 root
  Sent 55151 bytes 555 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc mq 0: dev eth2 root
  Sent 38374148475 bytes 2774405 pkt (dropped 0, overlimits 0 requeues 4)
  rate 0bit 0pps backlog 0b 0p requeues 4

ifconfig -a:
http://pastebin.com/raw.php?i=M3QHQjSU

ethtool -S:
http://pastebin.com/raw.php?i=Eap05xKc

Thanks again,
Stefan
