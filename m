From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 09:32:57 -0800
Message-ID: <1322501577.2024.34.camel@Joe-Laptop>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322477197.2024.4.camel@Joe-Laptop>
	 <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322499255.2024.22.camel@Joe-Laptop>
	 <1322500843.26733.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48140 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751531Ab1K1Rc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 12:32:58 -0500
In-Reply-To: <1322500843.26733.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 17:20 +0000, Ben Hutchings wrote:
> On Mon, 2011-11-28 at 08:54 -0800, Joe Perches wrote:
> > Perhaps a checkpatch warning should be issued
> > when the implicit cast [to bool] is used.
> checkpatch can't do type-checking; maybe you mean sparse.

I think I could get checkpatch to track the bool
type implicit casts for the not struct member
uses of bool.

ie:
	bool foo;
	[...]
	foo = expr;
but not:
	struct foo {
		bool bar;
	};
	[...]
	foo.bar = expr;

It's pretty trivial to do it mostly correctly
with spatch/cocci though.
