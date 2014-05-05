From: Rick Jones <rick.jones2@hp.com>
Subject: Re: network performance get regression from 2.6 to 3.10 by each version
Date: Mon, 05 May 2014 09:44:34 -0700
Message-ID: <5367BFF2.50803@hp.com>
References: <CANHbGWu0SXtSSHDz=m6KCKOL7AESWB8GHbvqYJMUyvJpTZZDKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: V JobNickname <workofv@gmail.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:21875 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbaEEQop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 12:44:45 -0400
In-Reply-To: <CANHbGWu0SXtSSHDz=m6KCKOL7AESWB8GHbvqYJMUyvJpTZZDKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2014 12:40 PM, V JobNickname wrote:
> I have an ARM platform which works with older 2.6.28 Linux Kernel and
> the embedded NIC driver
> I profile the TCP Tx using netperf 2.6 by command "./netperf -H
> {serverip} -l 300".

Is your ARM platform a multi-core one?  If so, you may need/want to look 
into making certain the assignment of NIC interrupts and netperf have 
remained constant through your tests.  You can bind netperf to a 
specific CPU via either "taskset" or the global -T option.  You can 
check the interrupt assignment(s) for the queue(s) from the NIC by 
looking at /proc/interrupts and perhaps via other means.

It would also be good to know if the drops in throughput correspond to 
an increase in service demand (CPU per unit of work).  To that end, 
adding a global -c option to measure local (netperf side) CPU 
utilization would be a good idea.

Still, even armed with that information, tracking down the regression or 
regressions will be no small feat particularly since the timespan is so 
long.  A very good reason to be trying the newer versions as they 
appear, even if only briefly, rather than leaving it for so long.

happy benchmarking,

rick jones
