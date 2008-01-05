From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Question about arp_error_report() (IPV4): clarification
Date: Sat, 5 Jan 2008 10:43:24 +0200
Message-ID: <147a89290801050043p24b3a116j75dc58954cdf8ed7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:35978 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbYAEIn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 03:43:28 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3780681fga.17
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 00:43:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
In neigh_timer_handler( ),  (core/neighbour.c), there is a comment which says:

# It is very thin place. report_unreachable is very complicated
# routine. Particularly, it can hit the same neighbour entry!

#  So that, we try to be accurate and avoid dead loop. --ANK

I tried to figure exactly what this comment mean (when dealing with IPV4).
 Can someone elaborate in 3-4 sentences on it ?


Why  "hit the same neighbour entry" can cause any complications ?
Why is report_unreachable() considered complicated ?
It seems to be simple, or am I missing something?


As far as I understand, eventually  ipv4_link_failure()
(net/ipv4/route.c) is called when  report_unreachable() is invoked.

(The path is: arp_error_report() calls dst_link_failure(skb), which in
case of ipv4, calls ipv4_link_failure().)
So it seems simply a matter of calling eventually ipv4_link_failure(),
which ends up with generating ICMP.

Regards,
Andy
