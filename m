From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] packet: packet_getname_spkt: make sure string is
 always 0-terminated
Date: Thu, 13 Jun 2013 18:05:53 +0100
Message-ID: <1371143153.2246.10.camel@bwh-desktop.uk.level5networks.com>
References: <1371045747-15203-1-git-send-email-dborkman@redhat.com>
	 <20130613.013859.1357765580190105873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8738 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756785Ab3FMRF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 13:05:58 -0400
In-Reply-To: <20130613.013859.1357765580190105873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 01:38 -0700, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 12 Jun 2013 16:02:27 +0200
> 
> > uaddr->sa_data is exactly of size 14, which is hard-coded here and
> > passed as a size argument to strncpy(). A device name can be of size
> > IFNAMSIZ (== 16), meaning we might leave the destination string
> > unterminated. Thus, use strlcpy() and also sizeof() while we're
> > at it. We need to memset the data area beforehand, since strlcpy
> > does not padd the remaining buffer with zeroes for user space, so
> > that we do not possibly leak anything.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> Applied, and queued up for -stable, thanks.

I don't think this should be applied anywhere.  Dropping support for
14-character device names is a regression.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
