From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Wed, 12 Feb 2014 22:32:05 -0800
Message-ID: <1392273125.2214.25.camel@joe-AO722>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:47390 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751174AbaBMGcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 01:32:08 -0500
In-Reply-To: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-12 at 20:51 -0800, Stephen Hemminger wrote:
> One of my pet coding style peeves is the practice of
> adding extra return; at the end of function.
> Kill several instances of this in network code.
> I suppose some coccinelle wizardy could do this automatically.

Maybe, but grep version 2.5.4 will show most of them.

$ grep-2.5.4 -rP --include=*.[ch] "return;\n}" *
[...]

Fixing them has to make sure that there's no
label before the close brace.

gcc has to have a statement before the close brace
of a void return after a label.

label:
}

must be:

label:
	;
}

to compile.
