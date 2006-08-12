From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
Date: Sat, 12 Aug 2006 22:05:48 +0200 (CEST)
Message-ID: <46805.81.207.0.53.1155413148.squirrel@81.207.0.53>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <33471.81.207.0.53.1155401489.squirrel@81.207.0.53>
    <1155404014.13508.72.camel@lappy>
    <47227.81.207.0.53.1155406611.squirrel@81.207.0.53>
    <1155408846.13508.115.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Daniel Phillips" <phillips@google.com>,
	"Rik van Riel" <riel@redhat.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helium.samage.net ([83.149.67.129]:5025 "EHLO helium.samage.net")
	by vger.kernel.org with ESMTP id S964949AbWHLUGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 16:06:04 -0400
In-Reply-To: <1155408846.13508.115.camel@lappy>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, August 12, 2006 20:54, Peter Zijlstra said:
>  - single allocation group per packet - that is, when I free a packet
> and all its associated object I get my memory back.

This is easy.

>  - not waste too much space managing the various objects

This too, when ignoring clones and COW.

> skb operations want to allocate various sk_buffs for the same data
> clones. Also, it wants to be able to break the COW or realloc the data.

So this seems to be what adds all the complexity.

> So I tried manual packing (parts of that you have seen in previous
> attempts). This gets hard when you want to do unlimited clones and COW
> breaks. To do either you need to go link several pages.

It gets messy quite quickly, yes.

> So needing a list of pages and wanting packing gave me SROG. The biggest
> wart is having to deal with higher order pages. Explicitly coding in
> knowledge of the object you're packing just makes the code bigger - such
> is the power of abstraction.

I assume you meant "Not explicitly coding in", or else I'm tempted to disagree.
Abstraction that has only one user which uses it in one way only adds bloat.
But looking at the code a bit more I'm afraid you're right.

Greetings,

Indan


