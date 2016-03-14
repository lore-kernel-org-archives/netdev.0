From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: ensure file->private_data can't be overridden
Date: Mon, 14 Mar 2016 20:09:28 +0100
Message-ID: <20160314190928.GR1186@alphalink.fr>
References: <3f04de903b6be9e1c30427830c0a1568478e0c6c.1457462784.git.g.nault@alphalink.fr>
 <20160311.144216.676727973447663610.davem@davemloft.net>
 <20160314175940.GB1462@alphalink.fr>
 <20160314.145759.727527672385295428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paulus@samba.org, alan@linux.intel.com,
	arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:35408 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcCNTJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20160314.145759.727527672385295428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 02:57:59PM -0400, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Mon, 14 Mar 2016 18:59:40 +0100
> 
> > Testing ->private_data without lock in ppp_ioctl() before calling
> > ppp_unattached_ioctl() is fine, because either ->private_data is
> > not NULL and thus is stable, or it is and ppp_unattached_ioctl()
> > takes care of not overriding ->private_data, should its value get
> > modified before taking the mutex.
> 
> This is exactly the ambiguous behavior I want you to avoid.
> 
> The decision should be atomic from ppp_ioctl()'s test all the way
> until ppp_unattached_ioctl() does it's work.

OK, will fix in v2.
