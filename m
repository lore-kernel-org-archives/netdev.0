From: roy.qing.li@gmail.com
Subject: question about vrf-lite
Date: Wed,  6 Jan 2016 17:53:42 +0800
Message-ID: <1452074022-11816-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44756 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcAFJxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 04:53:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Ahern:

when I test vrf-lite, I meet a question, could you help me?

the envirnment is below:
                                                 N2
           N1 (all configs here)          +---------------+
    +--------------+                      |               |
    |              |                      |               |
    |eth0 :10.0.2.1+----------------------+eth0 :10.0.2.2 |
    |              |                      +---------------+
    | VRF 1        |
    | table 5      |
    |              |
    +---------------+
    |              |
    | VRF 2        |                             N3
    | table 6      |                      +---------------+
    |              |                      |               |
    |eth1 :10.0.2.1+----------------------+eth0 :10.0.2.2 |
    +--------------+                      +---------------+

and configuration on N1 is below:

ip link add vrf1 type vrf table 5
ip link add vrf2 type vrf table 6
ip rule add pref 200 oif vrf1 lookup 5
ip rule add pref 200 iif vrf1 lookup 5
ip rule add pref 200 oif vrf2 lookup 6
ip rule add pref 200 iif vrf2 lookup 6
ip link set vrf1 up
ip link set vrf2 up
ip link set eth0 master vrf1
ip link set eth1 master vrf2

the route information is below:

# ip route get 10.0.2.2 oif vrf1
10.0.2.2 dev eth0  table 5  src 10.0.2.1 
    cache 
#
# ip route get 10.0.2.2 oif vrf2
10.0.2.2 dev eth1  table 6  src 10.0.2.1 
    cache 
#
#uname -r
4.4.0-rc5
# 

when run the ping with different interfaces on N1, I expect
"ping -I vrf1 10.0.2.2" send to/receive from packets with N2,
"ping -I vrf2 10.0.2.2" send to/receive from packets with N3,

but I found whether the interface is vrf1 or vrf2, the packets always
is sent out through eth0, N2 reply; and no packets sent out through
eth1.

is it right?

thanks

-Roy
