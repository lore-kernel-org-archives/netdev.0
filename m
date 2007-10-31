From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: dev_ifname32() fails on 32->64bit calls in copy_in_user().
Date: Wed, 31 Oct 2007 02:03:23 -0600
Message-ID: <m1bqafk8xg.fsf@ebiederm.dsl.xmission.com>
References: <20071031003850.GE7517@tasint.org>
	<1193798124.9928.91.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Becker <Joel.Becker@oracle.com>,
	Linux Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <Linux-Kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57838 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbXJaID5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 04:03:57 -0400
In-Reply-To: <1193798124.9928.91.camel@pasglop> (Benjamin Herrenschmidt's
	message of "Wed, 31 Oct 2007 13:35:24 +1100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> Bug is in the new dev_ifname32:
>
> 	uifr = compat_alloc_user_space(sizeof(struct ifreq));
> 	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)));
> 		return -EFAULT;
>
> There's a stray ";" after the if statement, that was obviously not
> tested :-)

Grr sorry about that, and thanks for catching this.

Eric


> This fixes it here (tested):
> ----------------------------------------------------------------------------
> [PATCH] Fix new dev_ifname32 returning -EFAULT
>
> A stray semicolon slipped in the patch that updated dev_ifname32 to
> not be inline, causing it to always return -EFAULT. This fixes it.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>
> Index: linux-work/fs/compat_ioctl.c
> ===================================================================
> --- linux-work.orig/fs/compat_ioctl.c	2007-10-31 13:30:42.000000000 +1100
> +++ linux-work/fs/compat_ioctl.c	2007-10-31 13:30:46.000000000 +1100
> @@ -322,7 +322,7 @@ static int dev_ifname32(unsigned int fd,
>  	int err;
>  
>  	uifr = compat_alloc_user_space(sizeof(struct ifreq));
> -	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)));
> +	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)))
>  		return -EFAULT;
>  
>  	err = sys_ioctl(fd, SIOCGIFNAME, (unsigned long)uifr);
