From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: build bug on kfree(struct sk_buff*)
Date: Sun, 15 Mar 2009 19:33:28 +0000
Message-ID: <1237145608.4209.49.camel@hashbaz.i.decadent.org.uk>
References: <49BA8710.20808@gmail.com> <49BAE95D.7060001@gmail.com>
	 <49BD2FDF.5050504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51205 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759531AbZCOTde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 15:33:34 -0400
In-Reply-To: <49BD2FDF.5050504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-03-15 at 17:42 +0100, Roel Kluin wrote:
> I noticed that my initial attempt was invalid. The one below appears to be
> correct, although I am not sure whether there is a better implementation.
> 
> this patch also fixes a kfree(skb) in net/core/dev.c, what do you think?
[...]

There are many types that should not be allocated and freed using the
general-purpose heap functions.  Why provide this check only for struct
skbuff?

Perhaps you should try to find a general way of detecting this, such as
a type annotation for sparse.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
