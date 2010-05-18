From: Henning Fehrmann <henning.fehrmann@aei.mpg.de>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Tue, 18 May 2010 13:12:16 +0000
Message-ID: <20100518131216.GA24750@localhost>
References: <4BEDCD87.4090602@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ox1.aei.mpg.de ([194.94.224.6]:38811 "EHLO ox1.aei.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281Ab0ERNMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 09:12:32 -0400
In-Reply-To: <4BEDCD87.4090602@kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

> >> Yeap, sure, it would be effective but I kind of want to leave
> >> bisection as the last resort.  Bisection is a somewhat painful process
> >> especially when the machine isn't right next to you and someone who
> >> has overall knowledge can often identify the problem much easier with
> >> appropriate debugging info.
> > 
> > Well nothing jumps to mind in the netpoll/netconsole code and I haven't
> > heard any similar reports. My guess is it's something obscure, so I
> > think the sooner you start bisecting... Even one or two tests will get
> > us a lot closer to figuring out what changed in the last 1.5 years.
> 
> I see.  I was hoping it would ring a bell to someone.  We'll probably
> try to provide the info Jesse asked and if that doesn't lead anywhere
> start bisecting.


Let me re-describe the symptoms.
I am not loading any ipmi related modules and not the netconsole
module.
When booting out current 2.6.32 kernel we can not access the IPMI
remotely.

We had one case where the IPMI card was accessible while using this
kernel but probably due to the fact that eth0 was removed. We do not
consider this case anymore. 

This problem does not occur when using an older kernel. 

It has likely nothing to do with netconsole.

Here is the bisecting result:

The sha1 sum of the first bad commit is: 
6e50912a442947d5fafd296ca6fdcbeb36b163ff

Hence, the last good commit has:
b2f8f7525c8aa1fdd8ad8c72c832dfb571d5f768

Cheers,
Henning
