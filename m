From: John Heffner <jheffner@psc.edu>
Subject: Re: SACK scoreboard
Date: Wed, 09 Jan 2008 13:23:06 -0500
Message-ID: <4785110A.4080707@psc.edu>
References: <20080108.144456.173014334.davem@davemloft.net>	 <p73sl17pwfy.fsf@bingen.suse.de> <47844D1C.1060706@psc.edu>	 <20080108.224144.234253941.davem@davemloft.net>	 <4784E090.8080303@psc.edu> <649aecc70801091014u50d1be26ndf5e59e0492ce9cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: SANGTAE HA <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:61627 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971AbYAISX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 13:23:26 -0500
In-Reply-To: <649aecc70801091014u50d1be26ndf5e59e0492ce9cd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SANGTAE HA wrote:
> On Jan 9, 2008 9:56 AM, John Heffner <jheffner@psc.edu> wrote:
>>>> I also wonder how much of a problem this is (for now, with window sizes
>>>> of order 10000 packets.  My understanding is that the biggest problems
>>>> arise from O(N^2) time for recovery because every ack was expensive.
>>>> Have current tests shown the final ack to be a major source of problems?
>>> Yes, several people have reported this.
>> I may have missed some of this.  Does anyone have a link to some recent
>> data?
> 
> I had some testing on this a month ago.
> A small set of recent results with linux 2.6.23.9 are at
> http://netsrv.csc.ncsu.edu/net-2.6.23.9/sack_efficiency
> One of serious cases with a large number of packet losses (initial
> loss is around 8000 packets) is at
> http://netsrv.csc.ncsu.edu/net-2.6.23.9/sack_efficiency/600--TCP-TCP-NONE--400-3-1.0--1000-120-0-0-1-1-5-500--1.0-0.5-133000-73-3000000-0.93-150--3/
> 
> Also, there is a comparison among three Linux kernels (2.6.13,
> 2.6.18-rc4, 2.6.20.3) at
> http://netsrv.csc.ncsu.edu/wiki/index.php/Efficiency_of_SACK_processing


If I'm reading this right, all these tests occur with large amounts of 
loss and tons of sack processing.  What would be most pertinent to this 
discussion would be a test with a large window, with delayed ack and 
sack disabled, and a single loss repaired by fast retransmit.  This 
would isolate the "single big ack" processing from other factors such as 
doubling the ack rate and sack processing.

I could probably set up such a test, but I don't want to duplicate 
effort if someone else already has done something similar.

Thanks,
   -John
