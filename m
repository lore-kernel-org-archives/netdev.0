From: Aubrey <aubreylee@gmail.com>
Subject: Re: Netpoll checksum issue
Date: Mon, 24 Apr 2006 16:04:35 +0800
Message-ID: <6d6a94c50604240104h190a314bm4e6617f7afba9a63@mail.gmail.com>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
	 <20060419103153.64ef0054@localhost.localdomain>
	 <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
	 <20060423113432.GA16424@gondor.apana.org.au>
	 <6d6a94c50604232242hd091922q8a2a0c78f1163b3c@mail.gmail.com>
	 <6d6a94c50604240046gcdcefev1c9c390c83ee5f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:43931 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751010AbWDXIEh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 04:04:37 -0400
Received: by nproxy.gmail.com with SMTP id l24so848043nfc
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 01:04:35 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <6d6a94c50604240046gcdcefev1c9c390c83ee5f7@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

The following change works properly on my side, it just do the same
thing as the driver not in netpoll mode. Let me know it's acceptable,
please.

Thanks,
-Aubrey
======================================================
int __netpoll_rx(struct sk_buff *skb)
{
----snip----
        if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
                goto out;

+++ skb->ip_summed = CHECKSUM_UNNECESSARY;

        len = ntohs(iph->tot_len);
        if (skb->len < len || len < iph->ihl*4)
                goto out;
----snip----
}
