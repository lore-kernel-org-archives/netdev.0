From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] net, ppp: Report correct error code if unit
	allocation failed
Date: Wed, 24 Nov 2010 12:49:01 +0000
Message-ID: <20101124124901.GA9268@ff.dom.local>
References: <20101123214344.GB1839@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LNML <netdev@vger.kernel.org>, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41395 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab0KXMtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 07:49:09 -0500
Content-Disposition: inline
In-Reply-To: <20101123214344.GB1839@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-11-23 22:43, Cyrill Gorcunov wrote:
> Allocating unit from ird might return several error codes
> not only -EAGAIN, so it should not be changed and returned
> precisely. Same time unit release procedure should be invoked
> only if device is unregistering.

IMHO this unit release fix should be in a separate patch.

...
> @@ -2668,10 +2668,10 @@ static void ppp_shutdown_interface(struc
>  		ppp->closing = 1;
>  		ppp_unlock(ppp);
>  		unregister_netdev(ppp->dev);
> +		unit_put(&pn->units_idr, ppp->file.index);
>  	} else
>  		ppp_unlock(ppp);
>  
> -	unit_put(&pn->units_idr, ppp->file.index);
>  	ppp->file.dead = 1;
>  	ppp->owner = NULL;
>  	wake_up_interruptible(&ppp->file.rwait);

Btw, it seems these last 3 lines could be moved similarly.

Jarek P.
