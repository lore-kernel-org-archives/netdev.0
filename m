From: Ronald Pina <pinaronald@gmail.com>
Subject: Change network device scheduling weight with sysfs using different
 wights for different devices.
Date: Fri, 27 Feb 2015 17:01:57 +0100
Message-ID: <CAONBAafVP9SmprVK3f0SSz_FaMm6YH0wxMjmLJE04HvoKSM2vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:45402 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbbB0QB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 11:01:58 -0500
Received: by igjz20 with SMTP id z20so1434521igj.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 08:01:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone
I am trying to change network device scheduling weight with sysfs, the
basic idea is that if i i have 3 network interfaces and i would like
to give more priority to  interface eth0 and smaller priority on eth1
and eth2. On the ingress traffic giving eth0 a weight of 64 means
that at every visit of the poll function will dequeue 64 frames, and
since the net_dev are are scheduled in round-robin manner on
net_rx_action , i would like to use a weight of 32 for eth1 meaning
low priority and a smaller time to dequeue frames the same for eth2
too. I am trying to achieve that ,it seems that the file for
configuring the weight is read only. Any help ?
Another issue i was thinking, in order to reduce the packet drop rate
of eth0 in case of a congestion , maybe would be experimental solution
to change the value RAND_LIE variable ( since this variable is a
dependent of mean of frames entering the queue and  and_max_backlog,
maybe we can manipulate this variable to minimize the packet drop of
eth0 ).
What do you think , how valuable is this idea?

I have try achieving that using traffic control tools on the egress
queue , the results are great, but i want to put hands on kernel
development and hacking code to achieve near results but this time on
the receive side on net_rx_action.

Best Regards
Ronald
