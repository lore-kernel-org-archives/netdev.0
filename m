From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch v3] fix stack overflow in pktgen_if_write()
Date: Mon, 1 Nov 2010 05:47:35 +0200
Message-ID: <20101101034721.GA14069@bicker>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com> <20101027221234.GN6062@bicker> <20101027224302.GQ6062@bicker> <20101027230657.GT16803@ksplice.com> <20101028060529.GX6062@bicker> <87lj5hud36.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nelson Elhage <nelhage@ksplice.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48526 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389Ab0KADrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 23:47:53 -0400
Received: by vws13 with SMTP id 13so3129863vws.19
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 20:47:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87lj5hud36.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > @@ -887,12 +887,17 @@ static ssize_t pktgen_if_write(struct file *file,
> >  	i += len;
> >  
> >  	if (debug) {
> > -		char tb[count + 1];
> > +		char *tb;
> > +
> > +		tb = kmalloc(count + 1, GFP_KERNEL);
> 
> 
> This is still trivially exploitable (for root) -- think what happens
> when count is near ULONG_MAX
> 

In vfs_write() we call rw_verify_area() which caps count at INT_MAX or
LONG_MAX.

        if (unlikely((ssize_t) count < 0))
                return retval;

So I get lucky this time...  ;)

regards,
dan carpenter
