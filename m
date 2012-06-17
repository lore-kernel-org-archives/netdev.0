From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Sun, 17 Jun 2012 09:53:51 +0300
Message-ID: <1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120613.153517.901328280865603627.davem@davemloft.net>
 <1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
 <20120614.133649.794229745961162963.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2076 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab2FQGyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 02:54:06 -0400
In-Reply-To: <20120614.133649.794229745961162963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 13:36 -0700, David Miller wrote:
> From: "Merav Sicron" <meravs@broadcom.com>
> Date: Thu, 14 Jun 2012 18:34:06 +0300
> 
> > That's why we think (and so does Eric Dumazet) that it is better
> > to have a smaller default number which is good for most cases.
> > Do you agree with that?
> 
> What I think is that the thing which is more important than the
> default we choose, is that it is consistently followed by all
> multiqueue drivers.
> 
> By blazing your own unique path here, that is nearly guaranteed not to
> happen.
> 
> I'd much rather have a bad default that every driver adheres to.
> 

The increasing number of CPUs together with the increasing number of
supported MSI-X vectors per device, is causing a lot of memory to be
allocated for the networking channels. This is a problem on low memory
platforms such as 32bits installations. 64 queues per device (and in
most cases, there are few devices) is a becoming a real problem.

If the device does not implement the ethtool .set_channels operation,
then the default is practically the only way to go, and there is no such
thing as a good default - it really depends on the use case. This is the
reason why we are only setting the default in the series that adds
support for this operation.

So what do you say about setting a new default only for devices that
supports .set_channels? There are only 2 of those right now (qlcnic,
bnx2 and hopefully bnx2x soon). Is it acceptable to keep the default
hard coded value or do you want it to be configurable? If the latter, is
a kernel parameter a valid option?

Please note that today, on a system with enough CPUs, you cannot really
tell how many channels will be created per device - each vendor is
allocating up to its HW limit - usually 8 or 16, but there is no easy
way to determine it beside reading the code. So adding a kernel
parameter to limit the number can actually increase the consistency.

Thanks,
Eilon
