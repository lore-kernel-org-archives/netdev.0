From: Mark Seger <Mark.Seger@hp.com>
Subject: update frequency for stats in /proc/net/dev
Date: Tue, 18 Dec 2007 08:37:26 -0500
Message-ID: <4767CD16.5050904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:58484 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751558AbXLRNhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 08:37:48 -0500
Received: from seeaxp.zko.hp.com (seeaxp.zko.hp.com [16.116.23.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by palrel10.hp.com (Postfix) with ESMTP id 27C27356C8
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 05:37:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of years ago I had written a comprehensive system monitoring 
tool called collectl, which among other things allowed me to monitor 
network traffic in real-time display as well as log the data to a file.  
Furthermore, that file can be generated in a format suitable for 
plotting with gnuplot.  As it turned out, I would very frequently see 
spikes of 200MB/sec on my 1Gb link.  A colleague noticed the reason was 
because the network counters were being updated every 0.9765 seconds and 
this was causing the problem.  I don't know how long this problem 
existed but it was certainly there in 2.4 kernels.  As it turns out, my 
tool is capable of monitoring with a fractional frequency and I have 
been able to get good data in spite of this problem.  However, I've 
since noticed that now the stats are updated once a second but that also 
means when I process the data at 0.9765 I get the wrong numbers again.  
Clearly one answer is to just update the counters more frequently but I 
suspect that is not being done for reasons of performance.

Anyhow, I just wanted to let people know that ALL tools that monitor 
once a second on older counters will get the wrong numbers and tools 
that correct for the wrong number by using fractional intervals (and I 
suspect mine is the only one that does) but run on newer kernels will 
also get the wrong numbers.  In any event, if anyone is interested in 
trying out collectl - it monitors a  LOT more than just networks - you 
can snag a copy of from http://collectl.sourceforge.net/ if you'd like 
to take if for a drive.  The website has a lot of output examples to 
give you a better idea what it can do.  I even included a writeup about 
the odd network performance observations at 
http://collectl.sourceforge.net/NetworkStats.html

-mark


