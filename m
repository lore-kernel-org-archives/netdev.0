From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 15:17:01 -0700
Message-ID: <1497565021.14396.21.camel@perches.com>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <20170615.121806.1737755943471705142.davem@davemloft.net>
         <1497554912.2518.9.camel@sipsolutions.net>
         <20170615.172637.978834439625255398.davem@davemloft.net>
         <1497562108.2518.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0035.hostedemail.com ([216.40.44.35]:42470 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750830AbdFOWRG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 18:17:06 -0400
In-Reply-To: <1497562108.2518.12.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 23:28 +0200, Johannes Berg wrote:
> On Thu, 2017-06-15 at 17:26 -0400, David Miller wrote:
> > 
> > > *skb_put(skb, 1) = 'x';
> > >  
> > > Seems pretty unlikely we have that, and in any case the compiler
> > 
> > would
> > > warn (error?) there if skb_put() becomes void.
> > 
> > Actually I am pretty sure I've seen a pattern like that somewhere. :-
> > )
> 
> Yeah, there are actually a ton of them, and oddly enough my spatch is
> failing to catch _one_ of them?? Still refining it :)

I suggest changing those to skb_put_char(skb, char)
in a first pass and then doing the other bits later.

Here's a script that does the conversion.

$ /usr/bin/git grep -P --name-only "\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-]+)\s*,\s*1\s*\)\s*=\s*([^;]+);" | \
  xargs perl -p -i -e 's/\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-]+)\s*,\s*1\s*\)\s*=\s*([^;]+);/skb_put_char(\1, \2);/'
