From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: ip monitor bug
Date: Sat, 15 Sep 2007 18:02:06 +0200
Message-ID: <46EC01FE.1050405@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:59515 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbXIOQCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 12:02:35 -0400
Received: from smtp1-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp1-g19.free.fr (Postfix) with ESMTP id 8F3441AB2CE
	for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 18:02:34 +0200 (CEST)
Received: from [192.168.1.62] (ns.popipo.fr [88.163.232.53])
	by smtp1-g19.free.fr (Postfix) with ESMTP id 6868F1AB2CA
	for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 18:02:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

I'd like to get feedbacks on the following scenario and whether it's a 
bug or not. Moreover, i'd like to know how to make a route permanent (ie 
never removed by the kernel).

# configure eth0 with IP 1.1.1.1
ifconfig eth0 1.1.1.1 up

# show routes added by the kernel (expected results)
ip route show dev eth0
1.0.0.0/8  proto kernel  scope link  src 1.1.1.1

# start ip monitor in background
ip monitor &

# add a specific route, properly reported by ip monitor (second line)
ip route add 192.168.168.168/32 dev eth0
192.168.168.168 dev eth0  scope link

# change eth0 IP address to 2.2.2.2
ifconfig eth0 2.2.2.2 up
Deleted 2: eth0    inet 1.1.1.1/8 brd 1.255.255.255 scope global eth0
Deleted 1.0.0.0/8 dev eth0  proto kernel  scope link  src 1.1.1.1
Deleted broadcast 1.255.255.255 dev eth0  table 255  proto kernel  scope 
link  src 1.1.1.1
Deleted broadcast 1.0.0.0 dev eth0  table 255  proto kernel  scope link  
src 1.1.1.1
Deleted local 1.1.1.1 dev eth0  table 255  proto kernel  scope host  src 
1.1.1.1
2: eth0    inet 2.2.2.2/8 brd 2.255.255.255 scope global eth0
local 2.2.2.2 dev eth0  table 255  proto kernel  scope host  src 2.2.2.2
broadcast 2.255.255.255 dev eth0  table 255  proto kernel  scope link  
src 2.2.2.2
2.0.0.0/8 dev eth0  proto kernel  scope link  src 2.2.2.2
broadcast 2.0.0.0 dev eth0  table 255  proto kernel  scope link  src 
2.2.2.2

# display routing table on eth0
ip route show dev eth0
2.0.0.0/8  proto kernel  scope link  src 2.2.2.2

So, the specific route (192.168.168.168/32) has been removed and ip 
monitor does not report it! I consider it to be a bug. I've been digging 
a bit into the kernel source code (devinet.c, fib_frontend.c) without 
much success.

Moreover, is there a way that the specific route (192.168.168.168/32) be 
keept even if eth0 IP changed?


Best regards,
Benoit
PS: Don't tell me about IP range, netmask and such, i've been using /32 
route for a while with IP in different ranges.

