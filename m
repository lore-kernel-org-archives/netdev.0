From: Yi Li <lovelylich@gmail.com>
Subject: Question: routing packets via specific router in LAN?
Date: Mon, 03 Sep 2012 14:04:48 +0800
Message-ID: <50444880.8080703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42036 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab2ICGEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 02:04:52 -0400
Received: by pbbrr13 with SMTP id rr13so7593355pbb.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 23:04:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I have server --- router ---client three machines,
and they all have only one ip in the same LAN.
I want to instruct the packets flowing through the router when the
server and client communicates.
I have do the following things to setup:
on the server:
# ip route add to unicast CLIENT_IP/32 via ROUTER_IP dev eth0
# echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
# echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects

on the client:
/*modify route table*/
# ip route add to unicast SERVER_IP/32 via ROUTER_IP dev eth0
/*disable icmp-redirects accept*/
# echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
# echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects

on the router:
/*enable forwarding*/
# echo 1 > /proc/sys/net/ipv4/ip_forwarding
/*disable icmp-redirects*/
# echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
# echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects

BTW, I have disabled iptables on all of these three machines.

But I still can't tcpdump any packets on the router which means no
packets flowing
through the router. The server and client communicates by pass the router!

So, What I have missed, or we can't setup server-router-client topo in LAN?
Thanks in advaced.
