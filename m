From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 16:58:58 +0200
Message-ID: <4C73DE32.1030802@nets.rwth-aachen.de>
References: <1282630819-23104-1-git-send-email-hkchu@google.com> <1282632262.2378.1681.camel@edumazet-laptop> <4C737D15.5060400@nets.rwth-aachen.de> <423116d1d215b0fb3d1c966fb8167508@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"H.K. Jerry Chu" <hkchu@google.com>, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:46091 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980Ab0HXO7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 10:59:37 -0400
In-Reply-To: <423116d1d215b0fb3d1c966fb8167508@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 24.08.2010 11:10, schrieb Hagen Paul Pfeifer:
> 
> On Tue, 24 Aug 2010 10:04:37 +0200, Arnd Hannemann wrote:
> 
>> Why not call it TCP_USERTIMEOUT?
> 
>> Later you can also send it via the TCP user timeout option... (RFC5482)
> 
>> Hmm... is the ms granularity really needed? Does it make sense to abort
> 
>> a connection below a second?
> 
> 
> 
> I am working on a patch for UTO, the lion share is already implemented. As

Nice, so did you come up with a name for the socket option yet?

> I can see this patch introduce a upper limit (max) where UTO on the other
> 
> hand provides a lower limit (min). Therefore I am not sure if we should
> 
> call this option TCP_USERTIMEOUT.

Hmm, is there really a difference? If an application specifies
a wanted timeout e.g. with USER_TIMEOUT, CHANGEABLE will
become false and the value would be announced via ADV_UTO.
The connection could be aborted locally after that time passed,
regardless of what the remote site thinks the timeout should be.

As I understand it U_LIMIT and L_LIMIT would only be there
for safety to disallow nonsensical values of USER_TIMEOUT.

Did I miss something?

Best regards,
Arnd
