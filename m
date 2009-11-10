From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 15:54:15 -0600
Message-ID: <4AF9E107.8050605@nortel.com>
References: <4AF9A63B.6010101@nortel.com>	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>	 <4AF9B2CF.6050305@nortel.com>	 <1257884799.3044.7.camel@heimdal.trondhjem.org>	 <4AF9D5D1.9040501@nortel.com> <1257888720.2834.30.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:49676 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758407AbZKJVzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 16:55:40 -0500
In-Reply-To: <1257888720.2834.30.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2009 03:32 PM, Ben Hutchings wrote:

> I'm sure we could afford 128 bytes for a blacklist of privileged ports.
> However, the problem is that there is no API for userland to request
> 'any free privileged port' - it has to just try binding to different
> ports until it finds one available.  This means that the kernel can't
> tell whether a process is trying to allocate a specifically assigned
> port or whether the blacklist should be applied.

That's unfortunate.  Maybe a bindresvport syscall would make sense, but
that's starting to get bloated.  At least for userspace apps netstat
will show who the owner is and it might be possible to clean it up
without rebooting.

For the ports allocated in the kernel via xs_get_random_port() and
xprt_bindresvport() it would be fairly easy to check a blacklist.

Interestingly, the current kernel range starts at 665 because IPMI is
known to use 664.  The current glibc range to be tried in bindresvport()
starts at 600, which seems to be a bug waiting to happen.

Chris
