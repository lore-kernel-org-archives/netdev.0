From: Aubrey <aubreylee@gmail.com>
Subject: Re: Netpoll checksum issue
Date: Mon, 24 Apr 2006 21:22:26 +0800
Message-ID: <6d6a94c50604240622v4cc3f0efi20429b474927c814@mail.gmail.com>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
	 <20060419103153.64ef0054@localhost.localdomain>
	 <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
	 <20060423113432.GA16424@gondor.apana.org.au>
	 <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
	 <20060424102250.GA24437@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:8007 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750742AbWDXNW1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 09:22:27 -0400
Received: by nproxy.gmail.com with SMTP id l24so892077nfc
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 06:22:26 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060424102250.GA24437@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Apr 24, 2006 at 01:42:12PM +0800, Aubrey wrote:
> >
> >   dev->last_rx = jiffies;
> >   skb->dev = dev;
> >   skb->protocol = eth_type_trans(skb, dev);
> >   skb->ip_summed = CHECKSUM_UNNECESSARY;
> >   netif_rx(skb);
>
> This doesn't make sense.  First of all you're setting ip_summed to
> CHECK_UNNECESSARY unconditionally which is most likely wrong.
>
> What's more, if this was the driver that you were using, then
> checksum_udp couldn't possibly fail since the first thing it does
> is check ip_summed.

Hmm, when I change the code in __netpoll_rx, there is no the following
one line in the driver:
==============================================
skb->ip_summed = CHECKSUM_UNNECESSARY;
==============================================

The above one line code in the driver is just a workaround.

Regards,
-Aubrey
