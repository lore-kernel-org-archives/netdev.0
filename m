From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 5/10] [NET]: Avoid unnecessary cloning for ingress filtering
Date: Mon, 15 Oct 2007 18:55:27 +0400
Message-ID: <20071015145527.GA11689@ms2.inr.ac.ru>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4p-00030c-00@gondolin.me.apana.org.au> <1192358991.4892.23.camel@localhost> <1192456665.4336.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:39221 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752282AbXJOO4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:56:07 -0400
Content-Disposition: inline
In-Reply-To: <1192456665.4336.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> If it is causing trouble, then one idea would be to move the resetting
> to a wrapper function which calls clone first and then resets the other
> fields. All actions currently cloning would need to be mod-ed to use
> that call.

I see not so many places inside net/sched/act* where skb_clone is used.
Exactly one in act_mirred.c, to be more exact. Did I miss something?

If you mean that place, your suggestion is correct and everything is OK.

But if there is at least one place where an external skb_clone()
should do this... this cannot be correct. Tell me, it does not matter
what some random skb_clone() makes with tc_verd, please. :-)

Alexey
