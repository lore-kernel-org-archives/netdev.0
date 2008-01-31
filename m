From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 12:35:48 +0100
Message-ID: <47A1B294.8080609@aei.mpg.de>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <47A0C5B2.1000500@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:53133 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765563AbYAaMNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:13:00 -0500
In-Reply-To: <47A0C5B2.1000500@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good morning (my TZ),

I'll try to answer all questions, hoewver if I miss something big, 
please point my nose to it again.

Rick Jones wrote:
>> As asked in LKML thread, please post the exact netperf command used to
>> start the client/server, whether or not you're using irqbalanced (aka
>> irqbalance) and what cat /proc/interrupts looks like (you ARE using MSI,
>> right?)
> 
netperf was used without any special tuning parameters. Usually we start 
two processes on two hosts which start (almost) simultaneously, last for 
20-60 seconds and simply use UDP_STREAM (works well) and TCP_STREAM, i.e.

on 192.168.0.202: netperf -H 192.168.2.203 -t TCP_STREAL -l 20
on 192.168.0.203: netperf -H 192.168.2.202 -t TCP_STREAL -l 20

192.168.0.20[23] here is on eth0 which cannot do jumbo frames, thus we 
use the .2. part for eth1 for a range of mtus.

The server is started on both nodes with the start-stop-daemon and no 
special parameters I'm aware of.

/proc/interrupts shows me PCI_MSI-edge thus, I think YES.

> In particular, it would be good to know if you are doing two concurrent 
> streams, or if you are using the "burst mode" TCP_RR with large 
> request/response sizes method which then is only using one connection.
> 

As outlined above: Two concurrent streams right now. If you think TCP_RR 
should be better I'm happy to rerun some tests.

More in other emails.

I'll wade through them slowly.

Carsten
