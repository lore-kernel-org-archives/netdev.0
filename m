From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Move in6_dev_hold under CONFIG_IPV6_PRIVACY
Date: Thu, 30 Aug 2012 08:25:21 -0700
Message-ID: <1346340321.2586.24.camel@edumazet-glaptop>
References: <503F3589.5070804@pace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Marchand <david.marchand@pace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61712 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab2H3PZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:25:26 -0400
Received: by pbbrr13 with SMTP id rr13so3309064pbb.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 08:25:26 -0700 (PDT)
In-Reply-To: <503F3589.5070804@pace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-30 at 11:42 +0200, David Marchand wrote:
> Hello,
> 
> I am currently looking at a problem with in6 interface refcnt on a 
> really old kernel and I have just noticed something I find suspicious in 
> all kernels until now.
> 
> The comment at net/ipv6/addrconf.c:396 suggests that the call to 
> in6_dev_hold is only for ipv6_regen_rndid.
> As a consequence, if CONFIG_IPV6_PRIVACY is not set, then this 
> in6_dev_hold will leak a refcnt.
> 
> Can someone look at this ?
> I did not test this patch, yet it looks reasonable to me.

Your patch was mangled by your email client, and its always safer to
test a patch...

Dont trust the comment, its a bit misleading.

Comment intent was to say :

/* One reference from device.  We must do this before
 * we eventually invoke __ipv6_regen_rndid().
 */
