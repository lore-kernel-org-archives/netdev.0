From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 13 Jul 2009 10:44:33 -0700 (PDT)
Message-ID: <20090713.104433.244099298.davem@davemloft.net>
References: <20090713133225.GA20946@urbino.open.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net
To: aj@open.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177AbZGMRo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 13:44:29 -0400
In-Reply-To: <20090713133225.GA20946@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Jaggi <aj@open.ch>
Date: Mon, 13 Jul 2009 15:32:25 +0200

> @@ -24,6 +24,7 @@
>  #define GRE_REC		__constant_htons(0x0700)
>  #define GRE_FLAGS	__constant_htons(0x00F8)
>  #define GRE_VERSION	__constant_htons(0x0007)
> +#define GRE_COPY_TOS	__constant_htons(0x0008)
>  
>  struct ip_tunnel_parm
>  {

This seems dangerious, and unnecessary.

If some future RFC defines this flag, we'll have to change
this and add ugly compat code to keep older tools working.

Why not just create a new IFLA_GRE_* attribute to pass in
flags like this that purely are private to the GRE Linux
tunnel driver and have nothing to do with values defined
by GRE tunnel headers at all?

I'm definitely not applying this as-is.
