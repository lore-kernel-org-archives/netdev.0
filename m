From: Mark Seger <Mark.Seger@hp.com>
Subject: Why are network counters only updated once a second?
Date: Mon, 14 Jan 2008 15:30:26 -0500
Message-ID: <478BC662.6030004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:51110 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbYANUbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 15:31:12 -0500
Received: from seeaxp.zko.hp.com (seeaxp.zko.hp.com [16.116.23.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by palrel12.hp.com (Postfix) with ESMTP id D449A346C9
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 12:31:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had mentioned this in my previous post but perhaps it might get more 
attention all by itself.  I can't say for sure when this changed, but 
for the longest time network counters were only updated once every 
0.9765 seconds and unless you used a tools like collectl that could 
monitor at fractional intervals, your traffic was under-reported AND 
you'd get periodic spikes of double the actual rate.  See 
http://collectl.sourceforge.net/NetworkStats.html for a more complete 
explanation.

Eventually the frequency became better aligned at a 1 second interval 
because now the number look better, but the problem I see is that when 
the sampling interval is very close to the monitoring interval you still 
get periodic incorrect data.  Furthermore, you now need to know which 
way the counters are updated before you pick a sampling interval!  But 
the real point is if anyone ever wants to do finer grained monitoring, 
say every 1/2 or even tenth of a second, they can't because the counters 
won't change between samples.  Has this ever been discussed before?

-mark


