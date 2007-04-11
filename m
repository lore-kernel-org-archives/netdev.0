From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 13:26:36 -0700
Message-ID: <461D447C.4070408@candelatech.com>
References: <461D2DEA.4010806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42202 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965338AbXDKU0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 16:26:37 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l3BKQalD015894
	for <netdev@vger.kernel.org>; Wed, 11 Apr 2007 13:26:36 -0700
In-Reply-To: <461D2DEA.4010806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Back in May of last year, I reported this problem, but worked
> around it at the time by changing the kernel memory settings
> in the networking stack.  I reproduced the problem again today
> with the previously working kernel memory settings..which is not
> supprising since I just papered over the bug last time.

So, I have been poking around.  Disabling tso makes the problem happen
sooner (< 1 minute).  Changing the tcp_congestion_control does not help.

Interestingly, I found this page mentioning a SACK problem in Linux:
http://www-didc.lbl.gov/TCP-tuning/linux.html

I tried disabling SACK, but the problem still happens.  However,
I do see the CWND go to 1 as soon as the connection stalls (I'm not
sure exactly which happens first.)  Before the stall, I see CWND
reported in the ~40 range.

Maybe something similar to the SACK bug can happen on very fast, very
low latency links, with large send/receive buffers configured?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

