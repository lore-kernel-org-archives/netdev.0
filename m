From: Brian Rak <brak@vultr.com>
Subject: Missing IPv4 routes
Date: Fri, 23 Oct 2015 17:34:11 -0400
Message-ID: <562AA7D3.9030905@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2015.choopa.net ([208.167.225.251]:37830 "EHLO
	mail2015.choopa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbJWVmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 17:42:52 -0400
Received: from [IPv6:2001:19f0:a06:600:c00:daf7:a19c:28fd] (unknown [IPv6:2001:19f0:a06:600:c00:daf7:a19c:28fd])
	by mail2015.choopa.net (Postfix) with ESMTPSA id 328345AC6396
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 17:34:12 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a weird situation here.  I have a route that the kernel knows 
about, but won't display via the general RTM_GETROUTE call, but will 
display if I query for that particular route:

# ip -4 route show | grep 108.61.171.x
# ip route get 108.61.171.x
108.61.171.x dev MYIF
     cache
# cat /proc/net/route | grep 108.61.171.x
#
# cat /proc/net/route  | grep -i 6c3dac
#
# ip route add 108.61.171.x dev MYIF
RTNETLINK answers: File exists
# ip route del 108.61.171.x  <---- it deletes successfully once
# ip route del 108.61.171.x
RTNETLINK answers: No such process


This is on a machine running 4.1.3, but I have seen it on earlier 
versions in the past.

I don't have great reproduction steps here, I've seen this 4-5 times in 
the past few months (on different hardware).  So far, I haven't really 
found any way of fixing it (deleting and readding the route has no 
effect).  I thought at first this might be related to 
e55ffaf457bcc8ec4e9d9f56f955971f834d65b3, but as far as I can tell that 
only relates to /proc/net/route.

Any suggestions on further troubleshooting here?  I'm all out of ideas 
(and since I can't easily reproduce it yet, I can't reboot to a newer 
kernel to see if it goes away)
