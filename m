From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 3 Jun 2009 08:45:41 +0000
Message-ID: <20090603084541.GB5644@ff.dom.local>
References: <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net> <20090603080123.GA5644@ff.dom.local> <4A263486.1030403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:48448 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbZFCIpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 04:45:46 -0400
Received: by fxm12 with SMTP id 12so7211646fxm.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 01:45:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A263486.1030403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 10:29:58AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Wed, Jun 03, 2009 at 09:53:11AM +0200, Patrick McHardy wrote:
>> ...
>>> Yes, it would work perfectly fine with usecs, which is actually (and
>>> unfortunately) the unit it uses in its ABI. But I think its better
>>> to convert the values once during initialization, instead of again
>>> and again when scheduling the watchdog. The necessary changes are
>>> really trivial, all you need to do when changing the scaling factors
>>> is to increase SM_MASK and decrease ISM_MASK accordingly.
>>
>> Right! (On the other hand we could consider a separate watchdog too...)
>
> We could :) But I don't see any benefit doing that, especially given
> that eventually everything should be using ns resolution anyways.

The main benefit would be readability... I guess it's no problem for
you, but I'm currently trying to make sure things like this are/will
be OK :-)

        dx = ((u64)d * PSCHED_TICKS_PER_SEC);
        dx += USEC_PER_SEC - 1;
 
Jarek P.
