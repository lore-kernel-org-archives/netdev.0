From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 0/2] Interface groups, round two
Date: Thu, 18 Oct 2007 12:15:13 +0200
Message-ID: <11927025171404-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Message-Id: <ifgroup-20071018-120757-1192702077-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Here is the new version of ifgroup patches.

The interface group value is u_int32_t in net_device which should be enough.
Previously it was an int.

Usage:
   ip link set eth0 group 4
but currently it cannot be unset, only changed to another value.

In /etc/iproute2/rt_ifgroup each value may have a symbolic name.

Netfilter part: xt_ifgroup module for both IPv4 and IPv6. Iptables usage:
   iptables -A INPUT -m ifgroup --in-ifgroup 4/0xf -j ACCEPT
   iptables -A FORWARD -m ifgroup --in-ifgroup 4 --out-ifgroup 5 -j ACCEPT
   ...

in the FORWARD chain both input and output interface group value should be matched
(with optional masks).

The following patches are:
  kernel: core part
  kernel: netfilter module, ifgroup match
  iproute2: showing and set ifgroup value
  iptables: ifgroup match
--
Laszlo Attila Toth
