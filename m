From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 3 Aug 2012 14:23:50 -0600
Message-ID: <20120803202350.GA7520@mail.gmail.com>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
 <20120803.015243.1041602621154758483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39789 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab2HCU0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 16:26:46 -0400
Received: by pbbrp8 with SMTP id rp8so1875284pbb.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 13:26:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120803.015243.1041602621154758483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Aug 2012 01:52:43 -0700
>
> From: Jean Sacren <sakiwit@gmail.com>
> Date: Fri,  3 Aug 2012 01:43:10 -0600
> 
> > Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> 
> > -	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> > -		(IN4_ADDR_HSIZE - 1));
> > +	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> > +	       (IN4_ADDR_HSIZE - 1);
> 
> Those parenthesis are there to make the evaluation order and
> grouping explicit.
> 
> The other ones you changed are wrong for similar reasons.

Barring the speed issue raised by Eric Dumazet, this patch is correct.

To illustrate, the patch merely changes

	return (A);

to

	return A;

where A is nothing but an expression, regardless if it is a simple one
or a compound one.

Whatever A is, it evaluates to a value. The parentheses do _not_
contribute to the evaluation. They do not alter precedence. They do not
make the evaluation order explicit. They are there to serve no purpose,
yet they do make return statement look like a function call.

Moreover, A is one single entity. It does not group with anything else.
I really don't see the significance of making A a group by itself.

Thank you for reviewing the patch. With all due respect, your assessment
is hard to agree with this moment.

-- 
Jean Sacren
