From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/6] rhashtable: Use a single bucket lock for sibling
 buckets
Date: Thu, 26 Feb 2015 14:38:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEEBB8@AcuExch.aculab.com>
References: <cover.1423097592.git.tgraf@suug.ch>
 <e99f9e9f3b8b2617698d88c1f2d42a1cf1414065.1423097592.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>
To: 'Thomas Graf' <tgraf@suug.ch>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:56618 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbbBZOjw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:39:52 -0500
In-Reply-To: <e99f9e9f3b8b2617698d88c1f2d42a1cf1414065.1423097592.git.tgraf@suug.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf
> Sent: 05 February 2015 01:04
> rhashtable currently allows to use a bucket lock per bucket. This
> requires multiple levels of complicated nested locking because when
> resizing, a single bucket of the smaller table will map to two
> buckets in the larger table. So far rhashtable has explicitly locked
> both buckets in the larger table.

> By excluding the highest bit of the hash from the bucket lock map and
> thus only allowing locks to buckets in a ratio of 1:2, the locking

Surely you mean 1:2^n ??

> can be simplified a lot without losing the benefits of multiple locks.
> Larger tables which benefit from multiple locks will not have a single
> lock per bucket anyway.

I'd presume that for a very large table the number of locks required
is related to the number of cpus rather than the table size itself.
Once the hash chains are short the lock is less likely to be contended
anyway. My brain can't think through the cache implications though.

This makes me think that you never really need to increase the number
of locks (which is probably quite tricky), and definitely don't need
to reduce the number of locks (probably harder).
This would mean that the table can't get smaller than the number of locks.
This in itself isn't really an issue.

	David
