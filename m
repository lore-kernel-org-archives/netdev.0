From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 09:36:03 +0100
Message-ID: <506955F3.8050304@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop>  <1348780624.5093.1767.camel@edumazet-glaptop>  <50656C4A.8090302@googlemail.com>  <1348831592.5093.2251.camel@edumazet-glaptop>  <5068648C.7050005@googlemail.com> <1349034330.12401.210.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37487 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab2JAIgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 04:36:03 -0400
Received: by bkcjk13 with SMTP id jk13so4744066bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 01:36:01 -0700 (PDT)
In-Reply-To: <1349034330.12401.210.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/30/12 20:45, Eric Dumazet wrote:
> On Sun, 2012-09-30 at 16:26 +0100, Chris Clayton wrote:
>> Hi Eric,
>>
>> On 09/28/12 12:26, Eric Dumazet wrote:
>>> On Fri, 2012-09-28 at 10:22 +0100, Chris Clayton wrote:
>>>
>>>> No, the WinXP guest is configured with a fixed IP address
>>>> (192.168.200.1). Subnet mask is 255.255.255.0, and default gateway is
>>>> 192.168.200.254. DNS is 192.168.0.1.
>>>>
>>>
>>> I have no problem with such a setup, with a linux guest.
>>>
>>> Could you send again a tcpdump, but including link-level header ?
>>> (option -e)
>>>
>>> Ideally, you could send two traces, one taken on tap0, and another taken
>>> on eth0.
>>>
>> Below are two more traces that I think may well be more useful than
>> those I sent on Friday. They are taken with tcpdump directly (after some
>> reading up on that application) rather than tcpdump translations of pcap
>> files captured with netsniff-ng. Also, they are taken concurrently, so
>> they show the traffic on tap0 and eth0 at the time of an unsuccessful
>> attempt to ping the router from the WinXP KVM client. The command was:
>> sudo tcpdump -nev -i eth0 -Z chris >eth0.trace
>
>
> Could you send "netstat -s" before/after your tests ?
>
Before:

$ netstat -s
Ip:
     485 total packets received
     10 forwarded
     0 incoming packets discarded
     473 incoming packets delivered
     383 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     12 active connections openings
     0 passive connection openings
     6 failed connection attempts
     0 connection resets received
     5 connections established
     374 segments received
     306 segments send out
     0 segments retransmited
     0 bad segments received.
     6 resets sent
Udp:
     164 packets received
     0 packets to unknown port received.
     0 packet receive errors
     67 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
error parsing /proc/net/snmp: Success

After:

$ netstat -s
Ip:
     519 total packets received
     21 forwarded
     0 incoming packets discarded
     496 incoming packets delivered
     406 requests sent out
Icmp:
     4 ICMP messages received
     4 input ICMP message failed.
     ICMP input histogram:
         echo replies: 4
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
IcmpMsg:
         InType0: 4
Tcp:
     13 active connections openings
     0 passive connection openings
     6 failed connection attempts
     0 connection resets received
     5 connections established
     381 segments received
     316 segments send out
     0 segments retransmited
     0 bad segments received.
     6 resets sent
Udp:
     173 packets received
     0 packets to unknown port received.
     0 packet receive errors
     69 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
error parsing /proc/net/snmp: Success

>
>
