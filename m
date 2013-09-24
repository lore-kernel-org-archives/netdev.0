From: Matthew Hall <mh@mhcomputing.net>
Subject: per-PID network stats files in /proc
Date: Tue, 24 Sep 2013 13:15:37 -0700
Message-ID: <20130924201536.GA3555@mhcomputing.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.mhcomputing.net ([74.208.46.186]:49399 "EHLO
	mail.mhcomputing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205Ab3IXUXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 16:23:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have an application that I'd like to make self-tuning, based upon the values 
of some of the network stats counters. Thus I went reading through a copy of 
linux-3.11.1 to look for some more information, and began exploring procfs as 
well.

I discovered some system-wide counters in /proc/net/snmp which are pretty 
interesting so I was trying to use the per-PID counters in 
/proc/net/PID/net/snmp as well.

Unfortunately I found that all of these files seem to be identical on my own 
system running Linux 3.2.0:

$ md5sum /proc/net/snmp /proc/1/net/snmp /proc/2/net/snmp
8b92b426f860d0667a780cd8baabb7bf  /proc/net/snmp
8b92b426f860d0667a780cd8baabb7bf  /proc/1/net/snmp
8b92b426f860d0667a780cd8baabb7bf  /proc/2/net/snmp

I found the snmp_seq_show function in net/ipv4/proc.c which prints these 
statistics to see how it really worked, but then I was having a hard time 
finding out what's really calling this code since it hooks up to the /proc 
framework.

Is there some option one can change which enables gathering the network 
statistics per-PID, or per-socket? This would be a tremendous help for my 
application.

Thanks,
Matthew.
