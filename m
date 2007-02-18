From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 18 Feb 2007 13:23:20 -0800
Message-ID: <f2b55d220702181323l5d2640a4g18df6d1ee051e987@mail.gmail.com>
References: <20070204074143.26312.qmail@science.horizon.com>
	 <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain>
	 <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
	 <20070218191009.GA28216@2ka.mipt.ru> <45D8B54A.70903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org,
	bcrl@linux.intel.com
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:25588 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbXBRVXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 16:23:22 -0500
Received: by nz-out-0506.google.com with SMTP id s1so1503069nze
        for <netdev@vger.kernel.org>; Sun, 18 Feb 2007 13:23:21 -0800 (PST)
In-Reply-To: <45D8B54A.70903@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A better data structure for RCU, even with a fixed key space, is
probably a splay tree.  Much less vulnerable to cache eviction DDoS
than a hash, because the hot connections get rotated up into non-leaf
layers and get traversed enough to keep them in the LRU set.  But I am
not a data structures guru; a stratified tree or van Emde-Boas
priority queue might be a better choice.  RCU splay tree has lots of
other potential applications inside the kernel, so it would make a fun
project for someone with time to burn.

Cheers,
- Michael
