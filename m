From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL (RTAB BUG)
Date: Thu, 20 Jul 2006 01:00:04 +0400
Message-ID: <20060719210004.GB20264@ms2.inr.ac.ru>
References: <1150843471.17455.2.camel@ras.pc.brisbane.lube> <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local> <1151000966.5392.34.camel@jzny2> <1151066247.4217.254.camel@ras.pc.brisbane.lube> <1151158431.6716.95.camel@jzny2> <1153188409.13145.5.camel@ras.pc.brisbane.lube> <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube> <44BE44E3.9080100@andyfurniss.entadsl.com> <Pine.LNX.4.61.0607192114240.9570@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Furniss <lists@andyfurniss.entadsl.com>,
	Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:7552 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030297AbWGSVET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 17:04:19 -0400
To: Jesper Dangaard Brouer <hawk@diku.dk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0607192114240.9570@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Guess that Alexey wrote these RTAB lookup in a time where array lookups 
> was faster... now we have that memory lookups are the bottleneck.

No, they were slower from the very beginning. If I remember correctly,
there is comment about this somewhere.

I just did not find any simple way to do 32 bit fixed point arithmetics
scaling from bps to Gbps and was lazy to investigate this further,
tables are much simpler and more flexible.


> What about removing the RTAB system entirely?

Well, if fixed point arithmetics is not a problem.

Plus, remember, the function is not R*size, it is at least
R*size+addend, to account for link overhead. Plus account for padding
of small packets. Plus, when policing it should deaccount already added
link headers, QoS counts only network payload.

Alexey
