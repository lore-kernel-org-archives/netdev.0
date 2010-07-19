From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Are concurrent calls to tc action ipt safe?
Date: Mon, 19 Jul 2010 16:23:40 +0200
Message-ID: <201007191623.40423.lists@egidy.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

AFAIK, current iptables has a short race condition when two rules within the 
same table are changed at once.

E.g. when two users simultaneously call something like this
iptables -t filter -A INPUT -s 192.168.1.1 -j MARK --set-mark 1
and
iptables -t filter -A INPUT -s 192.168.1.2 -j MARK --set-mark 2
one of these entries can get lost.

Jan Engelhard recently posted his xt2 patchset to overcome problems like this, 
but it seems to still have performance issues.

I have a set of simple rules which need to change often and are subject to 
this problem. I now wonder if I can solve this by using tc and the ipt action:

tc filter add dev eth0 parent ffff: protocol ip prio 1 u32  \
match ip src 192.168.1.1 \
action ipt -j MARK --set-mark 1

Since this call uses the xtables targets I'm currently not sure if the same 
problem regarding concurrent changes exists or not. Can anyone tell me if 
concurrent calls like this are safe?

Thank you very much.

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
