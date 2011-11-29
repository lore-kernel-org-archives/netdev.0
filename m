From: Rick Jones <rick.jones2@hp.com>
Subject: is non-inheritance of congestion control algorithm from the listen
 socket a bug or a feature?
Date: Tue, 29 Nov 2011 12:03:45 -0800
Message-ID: <4ED53AA1.9090800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:35414 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab1K2UDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 15:03:47 -0500
Received: from g4t0018.houston.hp.com (g4t0018.houston.hp.com [16.234.32.27])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id CDF68141F8
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 20:03:46 +0000 (UTC)
Received: from [16.89.64.213] (tardy.cup.hp.com [16.89.64.213])
	by g4t0018.houston.hp.com (Postfix) with ESMTP id 9599F100FA
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 20:03:46 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Taht asked me if I would consider adding control/reporting of the 
congestion control algorithm to netperf.  I'm in the midst of doing that 
and have noticed that setting a valid congestion control algorithm on a 
listen endpoint does not seem to be inherited by subsequent connections. 
  Rather than rely on netperf/netserver I cobbled-together a quick test 
program to show what I mean.

raj@raj-ubuntu-guest:~$ uname -a
Linux raj-ubuntu-guest 3.2.0-rc2+ #1 SMP Mon Nov 28 16:39:21 PST 2011 
x86_64 x86_64 x86_64 GNU/Linux

raj@raj-ubuntu-guest:~$ find /proc -name "*cong*" -print -exec cat {} \; 
2>/dev/null
/proc/sys/net/ipv4/tcp_congestion_control
cubic
/proc/sys/net/ipv4/tcp_available_congestion_control
cubic reno
/proc/sys/net/ipv4/tcp_allowed_congestion_control
cubic reno


# first just report what one gets
raj@raj-ubuntu-guest:~$ ./tcp_congestion_test
Will make no request to set congestion control algorithm
active socket has '' for congestion control
passive socket has '' for congestion control
after listen() passive socket has '' for congestion control
after connect() active has 'cubic' for congestion control
after accept() accepted has 'cubic' for congestion control

# now specify a valid alternative
raj@raj-ubuntu-guest:~$ ./tcp_congestion_test  reno
Will be requesting 'reno' as the congestion control algorithm
active socket has 'reno' for congestion control
passive socket has 'reno' for congestion control
after listen() passive socket has 'reno' for congestion control
after connect() active has 'reno' for congestion control
after accept() accepted has 'cubic' for congestion control

# now specify an invalid alternative just for completeness
raj@raj-ubuntu-guest:~$ ./tcp_congestion_test  bogus
Will be requesting 'bogus' as the congestion control algorithm
active socket has '' for congestion control
passive socket has '' for congestion control
after listen() passive socket has '' for congestion control
after connect() active has 'cubic' for congestion control
after accept() accepted has 'cubic' for congestion control

Is the non-inheritance of the congestion control algorithm a bug or a 
feature?

rick jones
