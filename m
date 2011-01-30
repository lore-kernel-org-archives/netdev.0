From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT
Date: Sun, 30 Jan 2011 13:26:14 +0100
Message-ID: <201101301326.14390.arnd@arndb.de>
References: <m18vy3uof7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62488 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab1A3M0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 07:26:34 -0500
In-Reply-To: <m18vy3uof7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 30 January 2011 03:15:56 Eric W. Biederman wrote:
> A trivial compact ioctl implementation would conflict with:
> SIOCAX25ADDUID
> SIOCAIPXPRISLT
> SIOCGETSGCNT_IN6
> SIOCGETSGCNT
> SIOCRSSCAUSE
> SIOCX25SSUBSCRIP
> SIOCX25SDTEFACILITIES

Since you have compiled the list, did you see if these are all handled
compatible, or would it make sense to create patches for the other
protocols as well, to handle them individually?

> This was necessary because unfortunately the struct layout for the SIOCGETSGCNT
> has unsigned longs in it so changes between 32bit and 64bit kernels.
> 
> This change was sufficient to run a 32bit ip multicast routing daemon on a
> 64bit kernel.
> 
> Reported-by: Bill Fenner <fenner@aristanetworks.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Looks good,

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

> +#ifdef CONFIG_COMPAT
> +static int compat_raw_ioctl(struct sock *sk, unsigned int cmd, unsigned long arg)
> +{
> +	switch (cmd) {
> +	case SIOCOUTQ:
> +	case SIOCINQ:
> +		return -ENOIOCTLCMD;

I would have suggested doing

	return raw_ioctl(sk, cmd, (unsigned long)compat_ptr(arg));

here, but returning -ENOIOCTLCMD is equivalent and correct. Your solution
is slightly more compact, the other one would be slightly faster.

	Arnd
