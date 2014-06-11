From: Per Jessen <per@computer.org>
Subject: Re: missing icmp redirects
Date: Wed, 11 Jun 2014 09:19:22 +0200
Message-ID: <539802FA.3040207@computer.org>
References: <5343FE4D.40805@computer.org>	<DUB123-W19EE656C7ECB42B9D05319ED6B0@phx.gbl>	<53974A0F.7080908@computer.org> <20140611000613.3fb3c563523b73244d90dc44@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lukas Tribus <luky-37@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.spamchek.net ([88.198.172.124]:39543 "EHLO
	outbound.spamchek.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaFKHTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:19:25 -0400
In-Reply-To: <20140611000613.3fb3c563523b73244d90dc44@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Popov wrote:
> On Tue, 10 Jun 2014 20:10:23 +0200
> Per Jessen <per@computer.org> wrote:
> 
>> Lukas Tribus wrote:
>>>> See complete description here:
>>>>
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=72561
>>>>
>>>> Summary - some ICMP redirects seem to be missing.
>>>>
>> Okay, I have devised a way to reproduce the problem:
>>
>> ...
> 
> It's probably not a bug, but intended behavior. See ip_rt_send_redirect in 
> net/ipv4/route.c. The kernel has a built-in per-source-address limiter for icmp
> redirects. 

Hi Dmitry

Any possibility that this limiter may have been inactive/faulty in e.g. 2.6.34? 
  We only hit this issue when we upgraded the firewall to a newer openSUSE (for 
ebtables) which came with kernel 3.11.6, but prior to that we had no issue with 
missing redirects.

> You can disable it for example with 
> echo -1 > /proc/sys/net/ipv4/route/redirect_silence
> Though I am not sure if it is ok in wild networks.

Okay, that worked on the first attempt.
Should I also be looking at the other redirect settings?

/proc/sys/net/ipv4/route/redirect_load
/proc/sys/net/ipv4/route/redirect_number



thanks
Per
