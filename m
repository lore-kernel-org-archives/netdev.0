From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,	comparing
 with 2.6.22
Date: Mon, 14 Jan 2008 10:44:40 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
References: <1199871330.3298.132.camel@ymzhang> <1200043854.3265.24.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58335 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbYANIom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 03:44:42 -0500
In-Reply-To: <1200043854.3265.24.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jan 2008, Zhang, Yanmin wrote:

> On Wed, 2008-01-09 at 17:35 +0800, Zhang, Yanmin wrote: 
> > The regression is:
> > 1)stoakley with 2 qual-core processors: 11%;
> > 2)Tulsa with 4 dual-core(+hyperThread) processors:13%;
> I have new update on this issue and also cc to netdev maillist.
> Thank David Miller for pointing me the netdev maillist.
> 
> > 
> > The test command is:
> > #sudo taskset -c 7 ./netserver
> > #sudo taskset -c 0 ./netperf -t TCP_RR -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -r 1,1
> > 
> > As a matter of fact, 2.6.23 has about 6% regression and 2.6.24-rc's
> > regression is between 16%~11%.
> > 
> > I tried to use bisect to locate the bad patch between 2.6.22 and 2.6.23-rc1,
> > but the bisected kernel wasn't stable and went crazy.

TCP work between that is very much non-existing.

Using git-reset's to select a nearby merge point instead of default 
commit where bisection lands might be help in case the bisected kernel 
breaks.

Also, limiting bisection under a subsystem might reduce probability of 
brokeness (might at least be able to narrow it down quite a lot), e.g.

git bisect start net/


-- 
 i.
