From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_probe: avoid modulus operation and wrap fix
Date: Sun, 24 Jan 2010 22:41:22 -0800 (PST)
Message-ID: <20100124.224122.13742906.davem@davemloft.net>
References: <20100124215001.78251e25@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752265Ab0AYGlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 01:41:10 -0500
In-Reply-To: <20100124215001.78251e25@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 24 Jan 2010 21:50:01 -0800

> @@ -75,12 +75,12 @@ static struct {
>  
>  static inline int tcp_probe_used(void)
>  {
> -	return (tcp_probe.head - tcp_probe.tail) % bufsize;
> +	return (tcp_probe.head - tcp_probe.tail) & (bufsize - 1);
>  }
>  
>  static inline int tcp_probe_avail(void)
>  {
> -	return bufsize - tcp_probe_used();
> +	return bufsize - tcp_probe_used() - 1;
>  }
>  
>  /*

Hmmm...  When the ring is full head==tail, which means
tcp_probe_used() returns 0.  Which would now make tcp_probe_avail()
return "bufsize - 0 - 1".

Is that right?
