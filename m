From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: ip_rt_min_delay : why 2s by default?
Date: Fri, 30 May 2008 12:37:06 +0200
Message-ID: <483FD8D2.1030604@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.112]:37170 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbYE3KhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 06:37:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm doing work on a IP routing protocol designed for mobility. During 
testing phase, I encounter some 2s delay when routing table are updated.

I compare the routing table (displayed by route -n) and the routing 
cache (displayed by route -Cn) and there was always a delay of 2s to 
propagate changes from the routing table to the routing cache. Hence, 
packet loss occurs.

Digging into the kernel source (net/ipv4/route.c), I found the 
ip_rt_min_delay variable which is indeed 2s. I changed it to 0 through 
/proc/sys/net/ipv4/route/min_delay and it seems that all my problems are 
gone.

Questions:

1/ Is it safe to put 0 in min_delay? I'd like to make sure that it will 
not trigger some bugs or inconsistencies later.

2/ If it is safe, then why it's not the default value? Is there a reason 
for 2s or is it simply a compromise that so far nobody cares about 2s delay?

Regards,
Benoit
PS: Test was done with a 2.6.21.6 kernel

