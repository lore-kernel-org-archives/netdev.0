From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 19:48:10 -0500 (EST)
Message-ID: <20130221.194810.1537678610059390209.davem@davemloft.net>
References: <1361485132.17413.19.camel@edumazet-glaptop>
	<20130221.181822.1234155083700257175.davem@davemloft.net>
	<m2fw0pxm6b.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab3BVAsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 19:48:13 -0500
In-Reply-To: <m2fw0pxm6b.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 21 Feb 2013 15:49:16 -0800

> murmur3

Two multiplies per mix(), no thanks.  We might as well use a universal
hash like the one we use for ARP hashing, which incurs only one
multiply.

jhash() is definitely going to perform much better than murmur3 on a
wide range of cpus.

jhash() is just a series of simple shifts and additions to mix the
data (which every cpu can do cheaply), whereas murmur3 is jhash()'s
overhead plus two multiplies per mix pass.

For our purposes, therefore, Jenkins is still superior.

> cityhash

And cityhash uses the two multiply mix() function from murmur3, thus
has the same problem.

These hashes actually look quite terrible for kernel hash table hashes.
