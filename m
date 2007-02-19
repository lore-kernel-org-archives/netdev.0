From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 19:13:07 +0100
Message-ID: <200702191913.08125.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <20070219142504.GA5626@2ka.mipt.ru> <200702191614.49666.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58632 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439AbXBSSNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 13:13:18 -0500
In-Reply-To: <200702191614.49666.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 February 2007 16:14, Eric Dumazet wrote:
>
> Because O(1) is different of O(log(N)) ?
> if N = 2^20, it certainly makes a difference.
> Yes, 1% of chains might have a length > 10, but yet 99% of the lookups are
> touching less than 4 cache lines.
> With a binary tree, log(2^20) is 20. or maybe not ? If you tell me it's 4,
> I will be very pleased.
>

Here is the tcp ehash chain length distribution on a real server :
ehash_addr=0xffff810476000000
ehash_size=1048576
333835 used chains, 3365 used twchains
Distribution of sockets/chain length
[chain length]:number of sockets
[1]:221019 37.4645%
[2]:56590 56.6495%
[3]:21250 67.4556%
[4]:12534 75.9541%
[5]:8677 83.3082%
[6]:5862 89.2701%
[7]:3640 93.5892%
[8]:2219 96.5983%
[9]:1083 98.2505%
[10]:539 99.1642%
[11]:244 99.6191%
[12]:112 99.8469%
[13]:39 99.9329%
[14]:16 99.9708%
[15]:6 99.9861%
[16]:3 99.9942%
[17]:2 100%
total : 589942 sockets

So even with a lazy hash function, 89 % of lookups are satisfied with less 
than 6 compares.

