From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Tue, 16 Jan 2007 19:39:31 -0800
Message-ID: <20070117033931.GX35756@gaz.sfgoth.com>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gaz.sfgoth.com ([69.36.241.230]:50631 "EHLO gaz.sfgoth.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbXAQDvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 22:51:49 -0500
To: Brandon Craig Rhodes <brandon@rhodesmill.org>
Content-Disposition: inline
In-Reply-To: <87bqky759v.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Craig Rhodes wrote:
> +	if (skb_tailroom(skb) < 4) {
> +		int err;
> +		err = skb_padto(skb, skb->len + 4);
> +		if (unlikely(err || skb_tailroom(skb) < 4)) {
> +			printk(KERN_DEBUG "Failed to increase tailroom"
> +			       " for TKIP encrypt");
> +			return err || -1;

The "||" operator in C doesn't act the same way it does in perl and ruby.
You're always returning 1 here.

+			return err || -1;

...and here as well.

-Mitch
