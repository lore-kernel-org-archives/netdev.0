From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Thu, 5 Feb 2015 15:56:15 +0530
Message-ID: <CA+CtxLRaJ+p=y1LCgap48vqH3b4VjxKQO55Yy5cyazng4WtxPw@mail.gmail.com>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
	<20150204.235308.71797582017426266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:39295 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbbBEK0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 05:26:16 -0500
Received: by mail-wi0-f177.google.com with SMTP id r20so9486215wiv.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 02:26:15 -0800 (PST)
In-Reply-To: <20150204.235308.71797582017426266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 1:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Wed, 4 Feb 2015 23:13:07 -0800
>
>> I'd like to see this patch reverted so we can have a more
>> comprehensive discussion/solution.  With this patch applied, the only
>> user (rocker) of NETDEV_SWITCH_FDB_ADD is broken.  So please undo this
>> patch so rocker isn't broken and let's work on a knob to suit both
>> modes: 1) let bridge manage aging, 2) let device manage aging.
>
> Patch reverted.

I now see why rocker is broken. Sorry for the churn.
As Scott/Roopa suggested, a new flag IFLA_BRPORT_AGING_SYNC (similar
to IFLA_BRPORT_LEARNING_SYNC) can be defined and stored in
net_bridge_port->flags when user configures it. Some thing like below.

$ sudo bridge link set dev swp1 ageing_sync on self

And bridge ageing logic does not age externally learnt entry *only* if
IFLA_BRPORT_AGING_SYNC flag on fdb entry's net_bridge_port is set.
This ensures that existing behavior continues to be default behavior
and is of no harm to rocker.

Please let me know your comments on above approach.
-- 
Regards,
Siva Mannem.
