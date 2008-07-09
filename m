From: Joe Perches <joe@perches.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Wed, 09 Jul 2008 11:20:49 -0700
Message-ID: <1215627649.5553.265.camel@localhost>
References: <20080708144725.5b663d19@infradead.org>
	 <20080708.145738.12692130.davem@davemloft.net>
	 <20080708164826.2a2d52c2@infradead.org>
	 <20080708.165304.55424424.davem@davemloft.net>
	 <20080708184456.52e94b93@infradead.org> <20080708201658.2c496b6a@speedy>
	 <1215624055.5553.252.camel@localhost>
	 <20080709105631.492f86bd@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1840 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbYGISZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 14:25:48 -0400
In-Reply-To: <20080709105631.492f86bd@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-09 at 10:56 -0700, Arjan van de Ven wrote:
> I don't like the size_t... size_t is an abstraction to deal with file
> sizes.... but there's nothing else wrong with using an int for numbers.

<pedant_mode>

o size_t is an abstraction to deal with arbitrary sizes
o an unnecessary <= 0 test exists
o using sizeof(drivername) reduces a dependency on a magic number
o netdev_drivername calls strlcpy with implicit cast to size_t

$ grep strlcpy include/linux/string.h
size_t strlcpy(char *, const char *, size_t);

Your choice.  Cheers, Joe

