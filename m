From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Thu, 10 Jan 2008 10:26:44 -0800
Message-ID: <47866364.1010501@intel.com>
References: <478654C3.60806@nortel.com> <478657C1.8040107@intel.com> <47865FFD.2010407@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23350 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756253AbYAJSvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 13:51:02 -0500
In-Reply-To: <47865FFD.2010407@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Kok, Auke wrote:
> 
>> You're using 2.6.10... you can always replace the e1000 module with the
>> out-of-tree version from e1000.sf.net, this might help a bit - the
>> version in the
>> 2.6.10 kernel is very very old.
> 
> Do you have any reason to believe this would improve things?  It seems
> like the problem lies in the NAPI/softirq code rather than in the e1000
> driver itself, no?

your real issue is that your userspace app is hogging the CPU. While network is
not really cpu intensive, it does require that ample time at many intervals is
given to the CPU to run cleanups and prevent FIFO issues.

alternatively, you can increase your rx/tx ring descriptor count (with ethtool),
which basically makes it easier for the hardware not to be serviced for a longer
period, since there are more buffers available and the card can go longer on when
userspace is hogging the CPU.

>> it also appears that your app is eating up CPU time. perhaps setting
>> the app to a
>> nicer nice level might mitigate things a bit.
> 
> If we're not handling the softirq work from ksoftirqd how would changing
> scheduler settings affect anything?

correct, it might not.

>> Also turn off the in-kernel irq
>> mitigation, it just causes cache misses and you really need the
>> network irq to sit
>> on a single cpu at most (if not all) the time to get the best
>> performance. Use the
>> userspace irqbalance daemon instead to achieve this.
> 
> Using userspace irqbalance would be some effort to test and deploy
> properly.  However, as a quick test I tried setting the irq affinity for
> this device and it didn't help.

irqbalance is a simple userspace app that drops into any system seemlessly and
does the best job all around - often it beats manual tuning of smp_affinity even ;)

Auke
