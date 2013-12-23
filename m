From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Mon, 23 Dec 2013 17:02:40 +0100 (CET)
Message-ID: <717e26b0-fda3-4c97-81a6-45e67462cb6b@mailpro>
References: <04e69925-f469-49b2-9988-9077eb7d50d7@mailpro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:40134 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757544Ab3LWQN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 11:13:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by mailpro.odiso.net (Postfix) with ESMTP id E34FB18032BC9
	for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 17:02:45 +0100 (CET)
Received: from mailpro.odiso.net ([127.0.0.1])
	by localhost (mailpro.odiso.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Q4D-ZMp9rv39 for <netdev@vger.kernel.org>;
	Mon, 23 Dec 2013 17:02:40 +0100 (CET)
Received: from mailpro.odiso.net (mailpro.odiso.net [10.1.31.112])
	by mailpro.odiso.net (Postfix) with ESMTP id 4EB091802511F
	for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 17:02:40 +0100 (CET)
In-Reply-To: <04e69925-f469-49b2-9988-9077eb7d50d7@mailpro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm trying to use vlan_filtering on bridge.

setup is : 2 qemu virtual machines (tap0 and tap1), plugged in a bridge br0.
           virtual machines don't tag packets.


qemuvm1 eth0 --tap0----->br0<-------tap1---qemuvm2 eth0.


with vlan_filtering disable, both vms can ping together.


If I enabled filtering

#echo 1 > /sys/class/net/br0/bridge/vlan_filtering

Both vms cannot ping together anymore.

So, I have tried to put vlan on tap interfaces with

#bridge vlan add dev tap0 vid 10
#bridge vlan add dev tap1 vid 10
#bridge vlan show
port	vlan ids
br0	None
tap0	10
tap1    10



But, it doesn't work.

tcpdump on bridge (tcpdump -i br0 -e -n) or in destination qemu (tcpdump -i eth0 -e -n) , don't see any packet

any idea ? 

Regards,

Alexandre Derumier
