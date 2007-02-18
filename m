From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 18 Feb 2007 14:04:24 -0800
Message-ID: <f2b55d220702181404l4c00e91eo94171aac56e80ce7@mail.gmail.com>
References: <20070204074143.26312.qmail@science.horizon.com>
	 <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	 <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
	 <20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
	 <f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:38903 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbXBRWE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 17:04:27 -0500
Received: by wr-out-0506.google.com with SMTP id i21so1412662wra
        for <netdev@vger.kernel.org>; Sun, 18 Feb 2007 14:04:26 -0800 (PST)
In-Reply-To: <f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/18/07, Michael K. Edwards <medwards.linux@gmail.com> wrote:
> ...  Much less vulnerable to cache eviction DDoS
> than a hash, because the hot connections get rotated up into non-leaf
> layers and get traversed enough to keep them in the LRU set.

Let me enlarge on this a bit.  I used to work for a company that built
a custom firewall/VPN ASIC with all sorts of special sauce in it,
mostly focused on dealing with DDoS.  Some really smart guys, some
really good technology, I hope they grab the brass ring someday.  On
the scale they were dealing with, there's only one thing to do about
DDoS: bend over and take it.  Provision enough memory bandwidth to
cold-cache every packet, every session lookup, and every
packet-processing-progress structure.  Massively parallelize, spinlock
on on-chip SRAM, tune for the cold-cache case.  If you can't afford to
do that -- and if you haven't designed your own chip, with separate
cache windows for each of these use cases, you can't, because they're
all retrograde loads for an LRU cache -- then a hash is not the right
answer.  The interaction between resizing and RCU is just the canary
in the coal mine.

Cheers,
- Michael
