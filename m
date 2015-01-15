From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] team: avoid possible underflow of count_pending
 value for notify_peers and mcast_rejoin
Date: Thu, 15 Jan 2015 08:42:50 +0100
Message-ID: <20150115074250.GA1876@nanopsycho.orion>
References: <1421255730-10681-1-git-send-email-jiri@resnulli.us>
 <20150114.165509.1466571325244320266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jbenc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:48901 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbAOHmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 02:42:53 -0500
Received: by mail-wg0-f45.google.com with SMTP id y19so13233387wgg.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 23:42:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150114.165509.1466571325244320266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 14, 2015 at 10:55:09PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 14 Jan 2015 18:15:30 +0100
>
>> This patch is fixing a race condition that may cause setting
>> count_pending to -1, which results in unwanted big bulk of arp messages
>> (in case of "notify peers").
>> 
>> Consider following scenario:
> ...
>> Fix this race by using atomic_dec_if_positive - that will prevent
>> count_pending running under 0.
>> 
>> Fixes: fc423ff00df3a1955441 ("team: add peer notification")
>> Fixes: 492b200efdd20b8fcfd  ("team: add support for sending multicast rejoins")
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Jiri Benc <jbenc@redhat.com>
>
>Applied, thanks.
>
>I am assuming that v3.12 and later need this fix, therefore I'm queueing it up for
>-stable.

Yes, thanks!
