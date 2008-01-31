From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:08:30 -0800
Message-ID: <47A20E9E.7070503@intel.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26869 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764597AbYAaSLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 13:11:30 -0500
In-Reply-To: <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen wrote:
> Hi Jesse,
> 
>>> It's good to be talking directly to one of the e1000 developers and
>>> maintainers.  Although at this point I am starting to think that the
>>> issue may be TCP stack related and nothing to do with the NIC.  Am I
>>> correct that these are quite distinct parts of the kernel?
>>
>> Yes, quite.
> 
> OK.  I hope that there is also someone knowledgable about the TCP stack
> who is following this thread. (Perhaps you also know this part of the
> kernel, but I am assuming that your expertise is on the e1000/NIC bits.)
> 
>>> Important note: we ARE able to get full duplex wire speed (over 900
>>> Mb/s simulaneously in both directions) using UDP.  The problems occur
>>> only with TCP connections.
>>
>> That eliminates bus bandwidth issues, probably, but small packets take
>> up a lot of extra descriptors, bus bandwidth, CPU, and cache resources.
> 
> I see.  Your concern is the extra ACK packets associated with TCP.  Even
> those these represent a small volume of data (around 5% with MTU=1500,
> and less at larger MTU) they double the number of packets that must be
> handled by the system compared to UDP transmission at the same data
> rate. Is that correct?


A lot of people tend to forget that the pci-express bus has enough bandwidth on
first glance - 2.5gbit/sec for 1gbit of traffix, but apart from data going over it
there is significant overhead going on: each packet requires transmit, cleanup and
buffer transactions, and there are many irq register clears per second (slow
ioread/writes). The transactions double for TCP ack processing, and this all
accumulates and starts to introduce latency, higher cpu utilization etc...

Auke
