From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 15:38:29 -0700
Message-ID: <1497566309.14396.25.camel@perches.com>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <20170615.121806.1737755943471705142.davem@davemloft.net>
         <1497554912.2518.9.camel@sipsolutions.net>
         <20170615.172637.978834439625255398.davem@davemloft.net>
         <1497562108.2518.12.camel@sipsolutions.net>
         <1497565021.14396.21.camel@perches.com>
         <1497565397.2518.18.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0061.hostedemail.com ([216.40.44.61]:50841 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752152AbdFOWie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 18:38:34 -0400
In-Reply-To: <1497565397.2518.18.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 00:23 +0200, Johannes Berg wrote:
> On Thu, 2017-06-15 at 15:17 -0700, Joe Perches wrote:
> 
> > Here's a script that does the conversion.
> > 
> > $ /usr/bin/git grep -P --name-only
> > "\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-]+)\s*,\s*1\s*\)\s*=\s*([^;]+);" |
> > \
> >   xargs perl -p -i -e 's/\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-
> > ]+)\s*,\s*1\s*\)\s*=\s*([^;]+);/skb_put_char(\1, \2);/'
> 
> Btw, this is incomplete - you have "\*\s*" at the beginning, but there
> are cases like
> 
>  *(skb_put(skb, 1)) = c;
> 
> where you have extra parentheses. By just adding them to the spatch, it
> finds both cases trivially.
> 
> I'm much more comfortable using spatch to do things like this.

Knock your self out.
Whatever floats your boat.
Have at it.
Go get 'em.

etc...

There are also some uses like:

	memcpy(skb_put(h5->rx_skb, 1), byte, 1);

that could also be converted.

cheers, Joe
