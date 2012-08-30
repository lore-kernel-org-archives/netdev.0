From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Move in6_dev_hold under CONFIG_IPV6_PRIVACY
Date: Thu, 30 Aug 2012 10:28:32 -0700
Message-ID: <1346347712.2586.29.camel@edumazet-glaptop>
References: <503F3589.5070804@pace.com>
	 <1346340321.2586.24.camel@edumazet-glaptop>  <503F9A30.6030100@pace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Marchand <david.marchand@pace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42432 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H3R2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:28:35 -0400
Received: by pbbrr13 with SMTP id rr13so3489537pbb.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 10:28:34 -0700 (PDT)
In-Reply-To: <503F9A30.6030100@pace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-30 at 18:52 +0200, David Marchand wrote:

> Mmm, ok.
> But if CONFIG_IPV6_PRIVACY is not selected, then I can't find where the associated in6_dev_put is done for this in6_dev_hold.
> Besides, __ipv6_regen_rndid is a "CONFIG_IPV6_PRIVACY-only" stuff.
> 

Okay.

Look at addrconf_ifdown(), line 2850

in6_dev_put(idev);

Will finally remove the last reference

With your patch, I guess there will be a reference problem, and possibly
call in6_dev_finish_destroy() too soon.

You are mistaken, because the reference taken in PRIVACY is at line 421,
right before calling ipv6_regen_rndid()

Look at following commit to have an idea of the underlying problem

http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=144d56e91044181ec0ef67aeca91e9a8b5718348
