From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ipv6: shouldn't dump the expired routes
Date: Thu, 26 Dec 2013 09:48:19 -0800
Message-ID: <20131226094819.613cee5b@nehalam.linuxnetplumber.net>
References: <52BBC5F9.4050904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:48065 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab3LZRsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 12:48:23 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so6629011pab.9
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 09:48:23 -0800 (PST)
In-Reply-To: <52BBC5F9.4050904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Dec 2013 14:00:25 +0800
Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:

> 
> If we execute the command "ip -6 route show table all", those routes
> that have been expired will be dumped.  But as everyone knows, those
> expired routes will not be used, and they will be deleted by the kernel.
> So why we still need to dump they, and just don't dump them.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

I can see three issues with this patch.

1. You are changing output of iproute2, and there is a slim chance somebody is
   expecting those routes in some test script.

2. Developers maybe using this to check that the expiration of routes is really
   working.

3. By making rt6_check_expired a global symbol, it can't be optimized as well in
   a potentially hot path for routing.

I am not saying the patch shouldn't go in, just raising the possibility that such
a seemingly trivial change could cause other impacts.
