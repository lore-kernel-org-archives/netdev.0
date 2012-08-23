From: Wei Huang <daviseago@gmail.com>
Subject: Which one is chosen on multiple default gateway set?
Date: Thu, 23 Aug 2012 14:31:26 +0800
Message-ID: <CAJPS4yY7sqqsOfhiouqjmfuW3Kof-ZzHEBs9E1+QoYYce01U4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

If multiple default gateways are set, which one will be chosen? And if
the chosen one is down, will others take over?

It works sometime, but not most of the time. (example below) The
behavior is inconsistent.

How the case is handled? On what condition another default gateway is
chosen?  Thank you!

=======================
~ # ip r
10.65.30.0/24 dev bond0  src 10.65.30.71
default via 10.65.30.221 dev bond0   (this one is down!)
default via 10.65.30.1 dev bond0
~ # ip r get 8.8.8.8
8.8.8.8 via 10.65.30.221 dev bond0  src 10.65.30.71
~ # ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss

// after a while

~ # ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=56 time=5.0 ms
~ # ip r get 8.8.8.8
8.8.8.8 via 10.65.30.1 dev bond0  src 10.65.30.71

// after two while


~ # ip r get 8.8.8.8
8.8.8.8 via 10.65.30.221 dev bond0  src 10.65.30.71
~ # ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
==================================

Best regards,
Wei
