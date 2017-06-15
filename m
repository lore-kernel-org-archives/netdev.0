From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Fri, 16 Jun 2017 00:21:16 +0200
Message-ID: <1497565276.2518.16.camel@sipsolutions.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <20170615.121806.1737755943471705142.davem@davemloft.net>
         <1497554912.2518.9.camel@sipsolutions.net>
         <20170615.172637.978834439625255398.davem@davemloft.net>
         <1497562108.2518.12.camel@sipsolutions.net>
         <1497565021.14396.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53960 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751789AbdFOWVW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 18:21:22 -0400
In-Reply-To: <1497565021.14396.21.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 15:17 -0700, Joe Perches wrote:

> I suggest changing those to skb_put_char(skb, char)

That might be something to think of, but you can't really know for sure
that they're not using len > 1 and don't yet care about the other bytes
or something. That'd probably be another bug, but ... dunno

And anyway, I think

*(u8 *)skb_put(skb, 1) = c;

isn't really that bad. Obviously that could be converted further to
skb_put_char(), using a simple spatch:

@@
expression SKB, C;
@@
- *(u8 *)skb_put(SKB, 1) = C;
+ skb_put_char(SKB, C);


> Here's a script that does the conversion.
> 
> $ /usr/bin/git grep -P --name-only
> "\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-]+)\s*,\s*1\s*\)\s*=\s*([^;]+);" |
> \
>   xargs perl -p -i -e 's/\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-
> ]+)\s*,\s*1\s*\)\s*=\s*([^;]+);/skb_put_char(\1, \2);/'

Uh, I think you're using the wrong tool for the job :-)

johannes
