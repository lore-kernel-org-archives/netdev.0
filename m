From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 09:11:56 +0200
Message-ID: <1497510716.2518.4.camel@sipsolutions.net>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
         <1497509862.2518.1.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8EFC@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45908 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750774AbdFOHL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 03:11:59 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15BC8EFC@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 07:05 +0000, YUAN Linyu wrote:
> > @@
> > type t;
> > expression skb, len;
> > identifier p;
> > @@
> > t *p
> > - = skb_put(skb, len);
> > + = skb_put_zero(skb, len);
> > -memset(p, 0, len);
> > 
> > and it can't figure out that it should remove the variable, without
> > much more work that's not really worth it for one instance :)
> 
> Yes, I agree, 
> it conflict with previous spatch which will keep "pad" variable,
> right?
> 
> I can do it by hand if spatch not work

I could teach spatch, but it's usually faster (for me) to post-process
the spatch changes to remove the extra variable - in this case though,
it's just not worth it at all since there's just a single change and
you already have a separate patch :)

Btw, just made a patch to add and use "skb_put_data()", just doing a
memcpy() into the skb_put() area also has lots of users.

johannes
