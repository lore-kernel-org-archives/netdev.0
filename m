From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 14:17:28 -0400 (EDT)
Message-ID: <20150527.141728.1015701398260699520.davem@davemloft.net>
References: <20150526233017.GB22391@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, dborkman@redhat.com,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbbE0SRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:17:30 -0400
In-Reply-To: <20150526233017.GB22391@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Tue, 26 May 2015 17:30:17 -0600

> sctp_v4_map_v6 was subtly writing and reading from members
> of a union in a way the clobbered data it needed to read before
> it read it.
> 
> Zeroing the v6 flowinfo overwrites the v4 sin_addr with 0, meaning
> that every place that calls sctp_v4_map_v6 gets ::ffff:0.0.0.0 as the
> result.
> 
> Reorder things to guarantee correct behaviour no matter what the
> union layout is.
> 
> This impacts user space clients that open an IPv6 SCTP socket and
> receive IPv4 connections. Prior to 299ee user space would see a
> sockaddr with AF_INET and a correct address, after 299ee the sockaddr
> is AF_INET6, but the address is wrong.
> 
> Fixes: 299ee123e198 (sctp: Fixup v4mapped behaviour to comply with Sock API)
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Applied and queued up for -stable, thakns.
