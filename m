From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Sun, 10 Jul 2011 12:07:32 -0700 (PDT)
Message-ID: <20110710.120732.419322076297775729.davem@davemloft.net>
References: <CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
	<20110708.153258.1997707802176810939.davem@davemloft.net>
	<CAL1RGDUzN_B0of0Ly6PxxaHM+A+E_1ZA0NTcC6jMmcrcoy0DxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756289Ab1GJTHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 15:07:44 -0400
In-Reply-To: <CAL1RGDUzN_B0of0Ly6PxxaHM+A+E_1ZA0NTcC6jMmcrcoy0DxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>
Date: Fri, 8 Jul 2011 16:11:00 -0700

> Maybe * of hash key with a random odd value is good enough?

Yes, from what I've read over the past few days it should
be.  More precisely:

	(key * hash_rnd) >> (32 - hash_table_size_log2)

where "hash_rnd" is odd.

The reason we want the top bits is because multiplies intrinsically
work such that bits in the inputs can only effect the same or higher
bits in the result.
