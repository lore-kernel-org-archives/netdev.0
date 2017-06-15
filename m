From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Fri, 16 Jun 2017 00:23:17 +0200
Message-ID: <1497565397.2518.18.camel@sipsolutions.net>
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
Received: from s3.sipsolutions.net ([5.9.151.49]:53972 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752414AbdFOWXX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 18:23:23 -0400
In-Reply-To: <1497565021.14396.21.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 15:17 -0700, Joe Perches wrote:

> Here's a script that does the conversion.
> 
> $ /usr/bin/git grep -P --name-only
> "\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-]+)\s*,\s*1\s*\)\s*=\s*([^;]+);" |
> \
>   xargs perl -p -i -e 's/\*\s*skb_put\s*\(\s*([\w\.\[\]\>\-
> ]+)\s*,\s*1\s*\)\s*=\s*([^;]+);/skb_put_char(\1, \2);/'

Btw, this is incomplete - you have "\*\s*" at the beginning, but there
are cases like

 *(skb_put(skb, 1)) = c;

where you have extra parentheses. By just adding them to the spatch, it
finds both cases trivially.

I'm much more comfortable using spatch to do things like this.

johannes
