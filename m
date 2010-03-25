From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Problem with talking to the kernel and iproute2/ifconfig
Date: Thu, 25 Mar 2010 17:00:35 +0100
Message-ID: <4BAB88A3.9070702@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:57901 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab0CYQHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 12:07:16 -0400
Received: from unknown (HELO [192.168.1.101]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp2.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 25 Mar 2010 16:00:34 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I have strange problem with kernel 2.6.33.1

I have script with 6267 ip's

cat gateways.conf | grep 'addr add' | wc -l
6267

and when i want to commit this interfaces by command:
ip -batch gateways.conf

I have only 680 ip interfaces
ip a | grep inet | grep ' 10.' | wc -l
680


I test this on kernels 2.6.29.1 and 2.6.30.1 and all was OK.
on kernel 2.6.29.1

ip -batch gateways.conf
ip a | grep inet | grep ' 10.' | wc -l
6267

on kernel 2.6.30.1
ip -batch gateways.conf
ip a | grep inet | grep ' 10.' | wc -l
6267


And also weird thing is that on kernel 2.6.33.1

ip addr ls dev vlan0100
158: vlan0100@eth2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noqueue=
=20
state DOWN qlen 100
     link/ether 00:30:48:67:fd:2e brd ff:ff:ff:ff:ff:ff

the same machine - the same interface but ifconfig use to list ip's
  ifconfig vlan0100
vlan0100  Link encap:Ethernet  HWaddr 00:30:48:67:fd:2e
           inet addr:10.0.0.1  Bcast:0.0.0.0  Mask:255.255.255.248
           BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


The same machine - with the same script that loads gateways but on=20
kernel 2.6.29.1
ip a ls dev vlan0100
8: vlan0100@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc htb=20
state UP qlen 100
     link/ether 00:30:48:d3:33:d6 brd ff:ff:ff:ff:ff:ff
     inet 10.0.0.1/29 brd 10.0.0.7 scope global vlan0100:1
     inet 10.0.0.25/29 brd 10.0.0.31 scope global vlan0100:2
     inet 10.0.0.49/29 brd 10.0.0.55 scope global vlan0100:3
     inet 10.0.0.121/29 brd 10.0.0.127 scope global vlan0100:4
     inet 10.0.0.129/29 brd 10.0.0.135 scope global vlan0100:5
     inet 10.0.0.153/29 brd 10.0.0.159 scope global vlan0100:6


Bests Regards
Pawe=C5=82
