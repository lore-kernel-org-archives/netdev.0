From: Alfred Monticello <ajmcello@yahoo.com>
Subject: ip route with duplicate ip addresses on two different interfaces
Date: Mon, 31 May 2010 15:26:14 -0700 (PDT)
Message-ID: <341685.37969.qm@web58302.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web58302.mail.re3.yahoo.com ([68.142.236.155]:41468 "HELO
	web58302.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755049Ab0EaW0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 18:26:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eth0 is 192.168.1.15 which is also part of my default network, with 192.168.1.1  being my default route. this works fine.

ppp0 is an outside provider, that sometimes gives me the same IP as what I have on eth0. sometimes I get a different IP for ppp0, but is still within the same subnet as eth0.

when adding the following rule, to try and make any packets seen from 192.168.1.15 on dev ppp0, it still routes out through eth0:

ip rule add from 192.168.1.15 dev ppp0 table ppp0 pref 100
ip route add default via 192.168.1.15 dev ppp0 table ppp0

what am I doing wrong that it won't let me route packets out through dev ppp0 with the same IP as eth0 or an IP within the same subnet as eth0? I suppose the easy answer is to change my default network on eth0, which does work with the following rules, as long as it doesn't match what is on eth0:

ip rule add from 192.168.1.15 table ppp0 pref 100
ip route add default via 192.168.1.15 dev ppp0 table ppp0

...but as soon as I add: 
 
     ip rule add from 192.168.1.15 dev ppp0 table ppp0 pref 100
     ip route add default via 192.168.1.15 dev ppp0 table ppp0

it will not route properly. I've tried using 192.168.1.15/32, 192.168.1.0/24 but not having any luck.

Thanks in advance.


      
