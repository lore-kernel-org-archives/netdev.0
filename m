From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Sun, 07 Dec 2014 14:14:40 +0100
Message-ID: <1417958080.17658.32.camel@localhost>
References: <20141207052041.20498.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, tgraf@suug.ch
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38363 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487AbaLGNOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 08:14:43 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id E53E7207CF
	for <netdev@vger.kernel.org>; Sun,  7 Dec 2014 08:14:42 -0500 (EST)
In-Reply-To: <20141207052041.20498.qmail@ns.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On So, 2014-12-07 at 00:20 -0500, George Spelvin wrote:
> If you want DoS-resistant hash tables, I'm working on adding SipHash
> to the kernel.
> 
> This is a keyed pseudo-random function designed specifically for that
> application.  I am starting with ext4 directory hashes, and then intended
> to expand to secure sequence numbers (since it's far faster than MD5).

Please consider xfs, too.
AFAIK xfs doesn't seed their hashing so far and the hashing function is
pretty weak. One example:
http://marc.info/?l=linux-xfs&m=139590613002926&w=2

> (I'm trying to figure out a good interface, since the crypto API
> is a bit heavy for something to heavily optimized.)

Ack. If we want to use it in the networking stack we should be able to
use it without a dependency to the crypto framework.

Bye,
Hannes
