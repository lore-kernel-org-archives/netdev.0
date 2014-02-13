From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 08:02:39 -0800
Message-ID: <20140213080239.3e70d546@nehalam.linuxnetplumber.net>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
	<1392273125.2214.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39295 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaBMQCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 11:02:44 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so10952466pab.12
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 08:02:43 -0800 (PST)
In-Reply-To: <1392273125.2214.25.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Feb 2014 22:32:05 -0800
Joe Perches <joe@perches.com> wrote:

> On Wed, 2014-02-12 at 20:51 -0800, Stephen Hemminger wrote:
> > One of my pet coding style peeves is the practice of
> > adding extra return; at the end of function.
> > Kill several instances of this in network code.
> > I suppose some coccinelle wizardy could do this automatically.
> 
> Maybe, but grep version 2.5.4 will show most of them.
> 
> $ grep-2.5.4 -rP --include=*.[ch] "return;\n}" *
> [...]
> 
> Fixing them has to make sure that there's no
> label before the close brace.
> 
> gcc has to have a statement before the close brace
> of a void return after a label.
> 
> label:
> }
> 
> must be:
> 
> label:
> 	;
> }
> 
> to compile.
> 

My method was to use:
 find . -name '*.c' | xargs grep -Pzo '(?s)^(\s*)\Nreturn;.}'
Then ignore cases where it was done for final label and where return
was alone in stub function.
