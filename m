From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 09 Oct 2012 15:54:23 +0200
Message-ID: <1349790863.21172.4406.camel@edumazet-glaptop>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45434 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843Ab2JINy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 09:54:28 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2662148bkc.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 06:54:26 -0700 (PDT)
In-Reply-To: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 14:47 +0100, Ian Campbell wrote:
> Hi Eric,
> 

Hi Ian

> Sander has discovered an issue where xen-netback is given a compound
> page as one of the skb frag pages to transmit. Currently netback can
> only handle PAGE_SIZE'd frags and bugs out.
> 
> I suspect this is something to do with 69b08f62e174 "net: use bigger
> pages in __netdev_alloc_frag", although perhaps not because it looks
> like only tg3 uses it and Sander has an r8169. Also tg3 seems to only
> call netdev_alloc_frag for sizes < PAGE_SIZE. I'm probably missing
> something.


Its not the commit you want ;)

> 
> Are all net drivers expected to be able to handle compound pages in the
> frags? Obviously it is to their benefit to do so, so it is something
> I'll want to look into for netback.
> 

Not sure why a net driver would care of COMPOUND page at all ?

a Fragment has a struct page *, and a size.

a page can be order-0, order-1, order-2, order-3, ...

> I expect the main factor here is bridging/forwarding, since the
> receiving NIC and its driver appear to support compound pages but the
> outgoing NIC (netback in this case) does not.
> 
> I guess my question is should I be rushing to fix netback ASAP or should
> I rather be looking for a bug somewhere which caused a frag of this type
> to get as far as netback's start_xmit in the first place?
> 
> Or am I just barking up the wrong tree to start with?



The problem comes because of 

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=5640f7685831e088fe6c2e1f863a6805962f8e81

And yes, we must find a way to cope with this problem in your driver,
because you can also benefit from increase of performance once fixed ;)

And yes I can certainly help, as I am the author of this patch ;)

Thanks
