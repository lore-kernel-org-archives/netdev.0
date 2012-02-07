From: Anisse Astier <anisse@astier.eu>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 7 Feb 2012 18:39:11 +0100
Message-ID: <20120207183911.4dd65ac8@destiny.ordissimo>
References: <20120107.121339.633839797125273714.davem@davemloft.net>
	<20120207121256.50667809@destiny.ordissimo>
	<4F31292F.2090503@parallels.com>
	<20120207.122931.1509587729423704935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50565 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab2BGRjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:39:20 -0500
Received: by wics10 with SMTP id s10so5081329wic.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 09:39:18 -0800 (PST)
In-Reply-To: <20120207.122931.1509587729423704935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Feb 2012 12:29:31 -0500 (EST), David Miller <davem@davemloft.net> wrote :

> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Tue, 07 Feb 2012 17:37:51 +0400
> 
> > @@ -409,7 +409,7 @@ config INET_TCP_DIAG
> >  
> >  config INET_UDP_DIAG
> >  	tristate "UDP: socket monitoring interface"
> > -	depends on INET_DIAG
> > +	depends on INET_DIAG && IPV6
> 
> This needs to be something like "INET_DIAG && (IPV6 || IPV6=n)"

Yes, this works better. This is the right solution.

Tested-by: Anisse Astier <anisse@astier.eu>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index aa2a2c7..d183262 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -409,7 +409,7 @@ config INET_TCP_DIAG
 
 config INET_UDP_DIAG
        tristate "UDP: socket monitoring interface"
-       depends on INET_DIAG
+       depends on INET_DIAG && (IPV6 || IPV6=n)
        default n
        ---help---
          Support for UDP socket monitoring interface used by the ss tool.
