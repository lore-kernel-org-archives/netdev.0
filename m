From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 16:06:51 -0700 (PDT)
Message-ID: <20070807.160651.98554604.davem@davemloft.net>
References: <20070805.232423.21363072.davem@davemloft.net>
	<adasl6vq8d1.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753525AbXHGXHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 19:07:01 -0400
In-Reply-To: <adasl6vq8d1.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 07 Aug 2007 15:37:30 -0700

>  >  		n = ib_poll_cq(priv->cq, t, priv->ibwc);
>  >  
>  > -		for (i = 0; i < n; ++i) {
>  > +		for (i = 0; i < n; i++) {
> 
> it might be nicer to avoid noise like this in the patch.

That one was just too much of an eye sore to ignore and it
effect my ability to audit the change I was making.

I mean, this is one of the first precise examples of kinds of
programming that lead to subtle bugs mentioned in The Practice of
Programming.

So this is staying in the patch, sorry.

> this goto back to the polling loop is a change in behavior.  When we
> were tuning NAPI, we found that returning in the missed event case and
> letting the NAPI core call the poll routine later actually performed
> better, because it allowed more work to pile up.

You weren't using your quantum, which is what you're supposed to do.

Sometimes using your quantum correctly won't perform optimally, but in
the interest of fairness and what NAPI wants, that is what you're
supposed to do, process work until you hit budget or there is no
more work.

Look, I'm not going to back down to every single tweak in every
driver.  All the drivers should handle this case consistently, and if
I have to edit every single driver to make this patch that is exactly
what I am going to do and enforce.

If you patch the ipoib driver behavior back afterwards, I will NAK
that patch every single time unless you make EVERY SINGLE OTHER DRIVER
do the same and thus retain the consistency.
