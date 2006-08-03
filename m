From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] llc: SOCK_DGRAM interface fixes
Date: Thu, 3 Aug 2006 14:52:17 -0700
Message-ID: <20060803215217.GA21836@kroah.com>
References: <20060803092117.5726b4d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:45482 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1030182AbWHCV5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 17:57:04 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060803092117.5726b4d7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 09:21:17AM -0700, Stephen Hemminger wrote:
> The datagram interface of LLC is broken in a couple of ways.
> These were discovered when trying to use it to build an out-of-kernel
> version of STP.
> 
> First it didn't pass the source address of the received packet
> in recvfrom(). It needs to copy the source address of received LLC packets
> into the socket control block. At the same time fix a security issue
> because there was uninitialized data leakage. Every recvfrom call
> was just copying out old data.
> 
> Second, LLC should not merge multiple packets in one receive call
> on datagram sockets. LLC should preserve packet boundaries on
> SOCK_DGRAM. 
> 
> This fix goes against the old historical comments about UNIX98 semantics
> but without this fix SOCK_DGRAM is broken and useless. So either ANK's
> interpretation was incorect or UNIX98 standard was wrong.

This doesn't apply at all to the current -stable tree, sorry.

greg k-h
