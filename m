From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] neigh: error out pending skbs if netlink invalidates
 incomplete neigh
Date: Thu, 11 Jun 2009 13:08:01 +0300
Message-ID: <4A30D781.2020403@iki.fi>
References: <1244104855-2129-1-git-send-email-timo.teras@iki.fi> <20090611.030207.238260652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:59856 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757302AbZFKKH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:07:58 -0400
Received: by ewy6 with SMTP id 6so1857582ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 03:08:00 -0700 (PDT)
In-Reply-To: <20090611.030207.238260652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Teras <timo.teras@iki.fi>
> Date: Thu,  4 Jun 2009 11:40:55 +0300
> 
>> The state transition code from incomplete to invalid via neigh_update()
>> is missing the proper clean up of skb queue. Separate the clean up
>> code from neigh_timer_handler() to a new function and make neigh_update()
>> is it also.
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> We don't error out pending SKBs on the state transition alone, we do
> it when we have the state transition _AND_ the number of probes
> exceeds the limit.
> 
> And it seems that behavior is very much intentional.
> 
> I'm not going to apply this.

When the state is changed to FAILED by netlink, the timer is stopped
and further probes are not tried anymore. This results in that the
skb's are not errored. The neigh entry is left stale.

The behaviour is flawed currently. Either we need to prevent state
change from INCOMPLETE -> FAILED via netlink and keep on sending probes,
or flush the queue when userland replies with FAILED. Otherwise the
neigh entry state is left bad.

- Timo

