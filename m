From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] net: dcb: match dcb_app protocol field
 with 802.1Qaz spec
Date: Mon, 31 Jan 2011 20:41:04 -0800 (PST)
Message-ID: <20110131.204104.226756946.davem@davemloft.net>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751789Ab1BAEk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:40:29 -0500
In-Reply-To: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 31 Jan 2011 14:00:49 -0800

> The dcb_app protocol field is a __u32 however the 802.1Qaz
> specification defines it as a 16 bit field. This patch brings
> the structure inline with the spec making it a __u16.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
 ...
> @@ -101,7 +101,7 @@ struct ieee_pfc {
>   */
>  struct dcb_app {
>  	__u8	selector;
> -	__u32	protocol;
> +	__u16	protocol;
>  	__u8	priority;
>  };
>  

If we're going to do this, please fix this wasteful structure
layout.  Put the "protocol" either first, or last, so that the
structure size is 4 bytes, rather than something like 8.
