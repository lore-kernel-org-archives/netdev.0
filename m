From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 04:37:01 +0100
Message-ID: <200711220437.01968.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071121190304.6bf682b5@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34864 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbXKVDhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 22:37:06 -0500
In-Reply-To: <20071121190304.6bf682b5@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I like this concept in general; I have one minor comment; right now
> your namespace argument is like
> 
> EXPORT_SYMBOL_NS(foo, some_symbol);
> 
> from a language-like pov I kinda wonder if it's nicer to do
> 
> EXPORT_SYMBOL_NS("foo", some_symbol);
> 
> because foo isn't something in C scope, but more a string-like
> identifier...

That wouldn't work for MODULE_ALLOW() because it appends the namespace
to other identifiers. I don't know of a way in the C processor to get
back from a string to a ## concatenable identifier.

For EXPORT_SYMBOL_NS it would be in theory possible, but making 
it asymmetric to MODULE_ALLOW would be ugly imho.

-Andi
