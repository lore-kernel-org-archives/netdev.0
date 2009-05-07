From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] iproute2/tc caching proposal
Date: Thu, 07 May 2009 20:44:52 +0200
Message-ID: <4A032C24.7060709@gmail.com>
References: <200905070103.37956.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:49855 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZEGSp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 14:45:56 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so971717fxm.37
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 11:45:57 -0700 (PDT)
In-Reply-To: <200905070103.37956.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote, On 05/07/2009 12:03 AM:

> Since already someone did caching in iproute2, my changes is very trivial, but 
> giving huge improvement in batch performance (30k rules 10minutes vs 30 
> seconds).
> 
> ll_init_map is called in many places in tc, but since tc not changing 
> anything, that can change this map, i think it is enough to call it only at 
> the beginning, after rtnl_open().
> 
> Only one exclusion - tc monitor, because it is running long time, and things 
> can change over this time, so we call ll_init_map on each received rtnetlink 
> event.


Do you mean 30 sec. is to short for a change? I don't know these things enough;
your idea looks very nice, but I wonder if you tested how it behaves if e.g.
after 15k rules some dev goes away which is used in the next 15k?

> 
> Also please check "[RFC] [IPROUTE2] Filter class output by classid", if it is 
> ok. Many people told it is useful patch.
> 


I agree it's useful and quite natural option.

Thanks,
Jarek P.
