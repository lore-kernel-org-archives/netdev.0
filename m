From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Disable "received packet with own address as source" check
Date: Sun, 3 Jan 2016 09:27:57 -0700
Message-ID: <56894C0D.9060401@cumulusnetworks.com>
References: <CADGFtMWL+G+Tq_qrtQ3iQ6QeJBk_vetZin5Wqh8RPpykADOJ=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Luca Dionisi <luca.dionisi@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33627 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbcACQ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 11:28:00 -0500
Received: by mail-ob0-f176.google.com with SMTP id bx1so207271458obb.0
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 08:28:00 -0800 (PST)
In-Reply-To: <CADGFtMWL+G+Tq_qrtQ3iQ6QeJBk_vetZin5Wqh8RPpykADOJ=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/2/16 9:25 AM, Luca Dionisi wrote:
> My linux box has a duty. It has to forward IP packets for a "private"
> network which it doesn't belong to.
>
> The network is "private" has the meaning that the hosts that belong to
> the network have IP addresses that are unique only between them.
>
> Say that the network is formed by 4 nodes: "a", "b", "c", "d", with
> their IP addresses: 10.0.1.1, ..., 10.0.1.4.
>
> The nodes "a", "b" and "c" are connected, but the only way from "c" to
> "d" is through my box, let's call it "x".
>
> The problem is that "x" has to live inside another "private" network,
> and in this other network the address of "x" is 10.0.1.4.
>
> When I send a PING-request from "c" to "d" the packet goes to a
> specific NIC of "x". Thanks to some carefully designed
> iptables+ip-rule tricks in "x", the PING-request is effectively
> relayed from "x" to the node "d", although "x" has the same IP as the
> destination of the packet.
>
> Now the node "d" sends a PING-reply to "c". This packet goes to a
> specific NIC of "x". There, the same tricks would send the packet to
> "c". But this is not happening.
>
> I suspect that the problem is that the box "x" refuses to relay a
> packet that has an IP source equal to one of its local IP addresses,
> although this IP is assigned to another NIC.
>
> I have this suspect because of the tcpdump traces that I have
> collected. But I don't seem to succeed in finding other evidences (I
> looked into dmesg and /var/log/syslog).
>
> Is there a tunable in linux to change this behaviour? I want to say to
> "x": When a packet comes in through NIC0, relay it without bothering
> if it has your IP as source address.


The VRF device added in 4.3 solves this problem.
https://www.kernel.org/doc/Documentation/networking/vrf.txt
