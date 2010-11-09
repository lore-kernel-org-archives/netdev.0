From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Tue, 09 Nov 2010 15:03:06 -0800
Message-ID: <1289343786.28590.56.camel@Joe-Laptop>
References: <1289341724.7380.13.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4809 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002Ab0KIXDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 18:03:07 -0500
In-Reply-To: <1289341724.7380.13.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-09 at 17:28 -0500, Dan Rosenberg wrote:
> The "mem" array used as scratch space for socket filters is not
> initialized, allowing unprivileged users to leak kernel stack bytes.

Hi Dan.

Using
	type var[count] = {};
instead of
	type var[count];
	...
	memset(var, 0, sizeof(var));

at least for gcc 4.4 and 4.5 generally results in smaller code.

$ size net/core/filter.o*
   text	   data	    bss	    dec	    hex	filename
   6751	     56	   1736	   8543	   215f	net/core/filter.o.memset
   6749	     56	   1736	   8541	   215d	net/core/filter.o.init


