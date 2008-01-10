From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Thu, 10 Jan 2008 12:12:13 -0600
Message-ID: <47865FFD.2010407@nortel.com>
References: <478654C3.60806@nortel.com> <478657C1.8040107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:56270 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbYAJSMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:12:37 -0500
In-Reply-To: <478657C1.8040107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:

> You're using 2.6.10... you can always replace the e1000 module with the
> out-of-tree version from e1000.sf.net, this might help a bit - the version in the
> 2.6.10 kernel is very very old.

Do you have any reason to believe this would improve things?  It seems 
like the problem lies in the NAPI/softirq code rather than in the e1000 
driver itself, no?

> it also appears that your app is eating up CPU time. perhaps setting the app to a
> nicer nice level might mitigate things a bit.

If we're not handling the softirq work from ksoftirqd how would changing 
scheduler settings affect anything?

 > Also turn off the in-kernel irq
> mitigation, it just causes cache misses and you really need the network irq to sit
> on a single cpu at most (if not all) the time to get the best performance. Use the
> userspace irqbalance daemon instead to achieve this.

Using userspace irqbalance would be some effort to test and deploy 
properly.  However, as a quick test I tried setting the irq affinity for 
this device and it didn't help.

One thing that might be of interest is that it seems to be bursty rather 
than gradual.  Here are some timestamps (in seconds) along with the 
number of overruns on eth0:

6552.15  overruns:260097
6552.69  overruns:260097
6553.32  overruns:260097
6553.83  overruns:260097
6554.35  overruns:260097
6554.87  overruns:260097
6555.41  overruns:260097
6555.94  overruns:260097
6556.51  overruns:260097
6557.07  overruns:260282
6557.58  overruns:260282
6558.23  overruns:260282


Chris
