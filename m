From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [RFC] iproute2: Fix meta match u32 with 0xffffffff
Date: Tue, 12 Apr 2011 19:22:05 +0200
Message-ID: <1302628925.3664.20.camel@lsx>
References: <20110411115234.74b5936b@nehalam> <1302595009.3664.8.camel@lsx>
	 <20110412081907.4f2e21fd@nehalam>
Reply-To: tgraf@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab1DLRWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 13:22:08 -0400
In-Reply-To: <20110412081907.4f2e21fd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-12 at 08:19 -0700, Stephen Hemminger wrote:

> > 
> > This is definitely much better but we still can't parse ULONG_MAX
> > as string representative. Checking glibc docs, the only way to do it is
> > to ignore the return value for error checking and look errno.
> > 
> 
> I think the error case is ret == ULONG_MAX && errno == ERANGE
> If there is no error, then strtoul doesn't set errno.

That's ok too but your patch adds ret == ULONG_MAX || errno == ERANGE
which will not allow to parse ULONG_MAX as a string. You probably
still have to clear errno to 0 before calling strtoul in case
ULONG_MAX is meant as legitimate return value but a previous glibc
function has left errno set to ERANGE.

