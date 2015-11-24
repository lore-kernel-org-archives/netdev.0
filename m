From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 10:49:15 -0500 (EST)
Message-ID: <20151124.104915.1283576168723043344.davem@davemloft.net>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
	<87y4dnfxl8.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com,
	davewatson@fb.com, alexei.starovoitov@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbbKXPtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 10:49:17 -0500
In-Reply-To: <87y4dnfxl8.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 24 Nov 2015 12:25:39 +0100

> Hello,
> 
> David Miller <davem@davemloft.net> writes:
> 
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Mon, 23 Nov 2015 09:33:44 -0800
>>
>>> The TCP PSH flag is not defined for message delineation (neither is
>>> urgent pointer). We can't change that (many people have tried to add
>>> message semantics to TCP protocol but have always failed miserably).
>>
>> Agreed.
>>
>> My only gripe with kcm right now is a lack of a native sendpage.
>> We should be able to zero copy data through KCM streams without
>> any problems whatsoever.
> 
> I understood from Tom's last mail that the messages are being
> constructed *in kernel memory* before sending out of the tcp
> socket. What advantage gives sendpage? The message construction must
> actually happen before to fill in the necessary headers for the length,
> so receiver can dissect again. Streaming semantics don't really fit
> here?

You can sendpage part of a filesystem file, and push the headers in
front (the "KCM stuff") without disturbing the page frags.
