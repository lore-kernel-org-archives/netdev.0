From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 00:53:18 -0500 (EST)
Message-ID: <20151119.005318.838757439536205791.davem@davemloft.net>
References: <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
	<20151118.224919.452852815199526735.davem@davemloft.net>
	<CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbKSFxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 00:53:22 -0500
In-Reply-To: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu, 19 Nov 2015 14:13:48 +0900

> On Thu, Nov 19, 2015 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>> The more I think about it more the more I agree with him and dislike
>> having user space make sure "it's ok", that isn't where TCP protocol
>> semantic rules are implemented.  It belongs in the kernel.
> 
> Today any app can always, on one of its sockets, set SO_LINGER with a
> timeout of 0 and call tcp_close. That results in immediately sending a
> RST and forgetting about local state. (Those semantics are the ones of
> RFC 793 ABORT.) If SOCK_DESTROY did that instead of just calling
> tcp_done, would that be acceptable?

What I object to is userspace making reachability decisions, not
whether SOCK_DESTROY closes the socket in one way or the other.
