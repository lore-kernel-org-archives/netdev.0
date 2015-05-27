From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 09:06:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
References: <20150526233017.GB22391@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jason Gunthorpe' <jgunthorpe@obsidianresearch.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:50842 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbE0JIj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 05:08:39 -0400
In-Reply-To: <20150526233017.GB22391@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe
> Sent: 27 May 2015 00:30
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
...
> This bugfix should be a candidate for -stable

Anyone know off-hand which kernel releases are affected?
I'm going to have to note this in the release notes for one of our products.

	David
