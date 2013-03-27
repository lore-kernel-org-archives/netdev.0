From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net : Fix broken IPv6 routing table after loopback
 down-up
Date: Wed, 27 Mar 2013 08:26:48 -0700
Message-ID: <1364398008.15753.14.camel@edumazet-glaptop>
References: <CAHPKR9KjB+6+WD9R4D81vZ6eFvcwgDJKgHFYvKxQQ2t_T7x9fg@mail.gmail.com>
	 <5152D012.4030805@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Balakumaran Kannan <kumaran.4353@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, Balakumaran.Kannan@ap.sony.com,
	maruthi.thotad@ap.sony.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f181.google.com ([209.85.210.181]:61789 "EHLO
	mail-ia0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3C0P0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:26:52 -0400
Received: by mail-ia0-f181.google.com with SMTP id o25so7292509iad.40
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 08:26:52 -0700 (PDT)
In-Reply-To: <5152D012.4030805@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-27 at 19:55 +0900, YOSHIFUJI Hideaki wrote:
> Balakumaran Kannan wrote:

> >  	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
> > +
> > +	while ((sp_dev = dev_get_by_index(dev_net(dev), i++))) {
> > +
> 
> I think this cannot work because we may have missing index.
> Why no dev_get_by_name()?

I might 'work' because lo interface index is 1 on all network
namespaces.

But yes, this ugly loop is not needed at all.
