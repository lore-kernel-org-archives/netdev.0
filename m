From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 09 Oct 2012 16:01:45 +0200
Message-ID: <1349791305.21172.4425.camel@edumazet-glaptop>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34880 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab2JIOCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 10:02:52 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2668683bkc.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 07:02:51 -0700 (PDT)
In-Reply-To: <1349790863.21172.4406.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 15:54 +0200, Eric Dumazet wrote:
> On Tue, 2012-10-09 at 14:47 +0100, Ian Campbell wrote:
> > Hi Eric,
> > 
> 
> Hi Ian
> 
> > Sander has discovered an issue where xen-netback is given a compound
> > page as one of the skb frag pages to transmit. Currently netback can
> > only handle PAGE_SIZE'd frags and bugs out.
> > 
> > I suspect this is something to do with 69b08f62e174 "net: use bigger
> > pages in __netdev_alloc_frag", although perhaps not because it looks
> > like only tg3 uses it and Sander has an r8169. Also tg3 seems to only
> > call netdev_alloc_frag for sizes < PAGE_SIZE. I'm probably missing
> > something.
> 
> 
> Its not the commit you want ;)

Hmm, I take it back. It also can give you the same problem :

We use this allocator for rx path of drivers : 

 __netdev_alloc_skb() 

So its now absolutely possible that one skb->head is backed by a order-3
page.

Is the problem coming from xen_netbk_count_skb_slots() ?

Give me more information if you want me to help.
