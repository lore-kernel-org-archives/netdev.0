From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 17:04:00 +0300
Message-ID: <20070219140400.GA21638@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru> <45D89EFE.4080103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@linux.intel.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51066 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbXBSOE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 09:04:56 -0500
Content-Disposition: inline
In-Reply-To: <45D89EFE.4080103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually for socket code any other binary tree will work perfectly ok -
socket code does not have wildcards (except listening sockets), so it is
possible to combine all values into one search key used in flat
one-dimensional tree - it scales as hell and allows still very high
lookup time.

As of cache usage - such trees can be combined with different protocols
to increase cache locality.

The only reason I implemented trie is that netchannels support
wildcards, that is how netfilter is implemented on top of them.

Tree with lazy deletion (i.e. without deletion at all) can be moved to 
RCU very easily.

-- 
	Evgeniy Polyakov
