From: Joe Perches <joe@perches.com>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Thu, 01 Mar 2012 20:13:22 -0800
Message-ID: <1330661602.1939.13.camel@joe2Laptop>
References: <20120302025554.GA13493@joana>
	 <20120301.221643.881299898523907213.davem@davemloft.net>
	 <20120301.222316.1877216960521396397.davem@davemloft.net>
	 <20120301.222604.1508242694024394849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gustavo@padovan.org, johan.hedberg@gmail.com,
	linville@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46496 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754174Ab2CBENY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 23:13:24 -0500
In-Reply-To: <20120301.222604.1508242694024394849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-01 at 22:26 -0500, David Miller wrote:
> You know what really pisses me off?  This is the one issue I made a huge
> stink about last week, arguments to function calls and prototypes lining
> up properl.  And it's in ever 2nd or 3rd commit in this pull request.
[]
> Come back when you've audited this whole thing properly and honestly.

I submitted a patch to checkpatch for a --strict rule for
this argument alignment.  https://lkml.org/lkml/2012/2/29/644

Are there any other tests you think should be added with
--strict?

Some I think possible are:

o no space after cast
	struct foo *bar = (struct foo *) baz;
sb:
	struct foo *bar = (struct foo *)baz;

o don't start comments with /*$
  (perhaps only if a blank line proceeds the comment)
	/*
	 * multiline comment
	 * ...
	 */
sb:
	/* multiline comment
	 * ...
	 */

o coalesce formats
	pr_<level>("format part 1 "
		   "format part 2\n", ...)
sb:
	pr_<level>("format part 1 format part 2\n",
		   ...);

o symmetric brace standardization
	if (foo) {
		bar;
		baz;
	} else
		bar;
sb:
	if (foo) {
		bar;
		baz;
	} else {
		bar;
	}

Any others?
