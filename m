From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Tue, 18 Dec 2012 08:13:00 -0800
Message-ID: <1355847180.9380.21.camel@edumazet-glaptop>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46405 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab2LRQUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:20:25 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so641456pad.20
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 08:20:24 -0800 (PST)
In-Reply-To: <1355844398.14620.254.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 15:26 +0000, Ian Campbell wrote:

> So actually we want += PAGE_SIZE * skb_shinfo(skb)->nr_frags ?
> 

I dont know what are the real frag sizes in your case.

Some drivers allocate a full page for an ethernet frame, others use half
of a page, it really depends.

As the frag ABI doesnt contain real size, its ok in this case to account
the actual frag size.

(skb->data_len in your driver)
