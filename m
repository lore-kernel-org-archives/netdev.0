From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 06 Aug 2009 20:40:32 -0700 (PDT)
Message-ID: <20090806.204032.39020854.davem@davemloft.net>
References: <20090806143959.GA29323@gondor.apana.org.au>
	<m1zladhtoh.fsf@fess.ebiederm.org>
	<20090807002243.GB1566@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, paul.moore@hp.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751384AbZHGDkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 23:40:23 -0400
In-Reply-To: <20090807002243.GB1566@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 7 Aug 2009 10:22:44 +1000

> tun: Extend RTNL lock coverage over whole ioctl
> 
> As it is, parts of the ioctl runs under the RTNL and parts of
> it do not.  The unlocked section is still protected by the BKL,
> but there can be subtle races.  For example, Eric Biederman and
> Paul Moore observed that if two threads tried to create two tun
> devices on the same file descriptor, then unexpected results
> may occur.
> 
> As there isn't anything in the ioctl that is expected to sleep
> indefinitely, we can prevent this from occurring by extending
> the RTNL lock coverage.
> 
> This also allows to get rid of the BKL.
> 
> Finally, I changed tun_get_iff to take a tun device in order to
> avoid calling tun_put which would dead-lockt as it also tries to
> take the RTNL lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This looks good after a quick audit, Eric what say you?
