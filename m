From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 15:11:25 +0300
Message-ID: <20070220121125.GA19927@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <20070219142504.GA5626@2ka.mipt.ru> <200702191614.49666.dada1@cosmosbay.com> <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43553 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932910AbXBTMRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 07:17:23 -0500
Content-Disposition: inline
In-Reply-To: <20070220092523.GA6238@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:25:23PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> And there is _no_ O(1) - O(1) is just a hash entry selection, then you
> need to add the whole chain path, which can be long enough.
> For example for the length 9 you have 1000 entries - it is exactly size
> of the tree - sum of all entries upto and including 2^9.
> One third of the table is accessible within 17 lookups (hash chain
> length is 1), but given into account size of the entry - let's say it 
> is equal to
> 32+32+32 - size of the key
> 32+32+32 - size of the left/right/parent pointer
> so 192 bytes per entry - given into acount that 1/4 of the 1-2 MB cache is

I just realized that it is in _BITS_, not in bytes, so typical trie/tree
entry is about 24 bytes - less than one cache line!

-- 
	Evgeniy Polyakov
