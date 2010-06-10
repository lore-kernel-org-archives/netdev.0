From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] allow to configure tcp_retries1 and tcp_retries2 per TCP socket
Date: Thu, 10 Jun 2010 19:00:19 +0200
Message-ID: <87bpbi4ycc.fsf@basil.nowhere.org>
References: <1276186161.2419.10.camel@topo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@firstfloor.org, "@vger.kernel.org"@firstfloor.org
To: Salvador Fandino <salvador@qindel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52784 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759498Ab0FJRAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 13:00:22 -0400
In-Reply-To: <1276186161.2419.10.camel@topo> (Salvador Fandino's message of "Thu\, 10 Jun 2010 18\:09\:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salvador Fandino <salvador@qindel.com> writes:


> The included patch adds support for setting the tcp_retries1 and
> tcp_retries2 options in a per socket fashion as it is done for the
> keepalive options TCP_KEEPIDLE, TCP_KEEPCNT and TCP_KEEPINTVL.
>
> The issue I am trying to solve is that when a socket has data queued for
> delivering, the keepalive logic is not triggered. Instead, the
> tcp_retries1/2 parameters are used to determine how many delivering
> attempts should be performed before giving up.

And why exactly do you need new tunables to solve this?

>
> The patch is very straight forward and just replicates similar
> functionality. There is one thing I am not completely sure and is if the
> new per-socket fields should go into inet_connection_sock instead of
> into tcp_sock.

tcp_sock is already quite big (>2k on 64bit) 

IMHO any new fields in there need very good justification.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
