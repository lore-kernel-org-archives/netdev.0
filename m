From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 22:41:12 +0200
Message-ID: <1348519272.26828.1670.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
	 <1348515547.26828.1538.camel@edumazet-glaptop>
	 <20120924124657.4541c186@nehalam.linuxnetplumber.net>
	 <1348517390.26828.1601.camel@edumazet-glaptop>
	 <20120924132637.17d89210@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36189 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757887Ab2IXUlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:41:17 -0400
Received: by bkcjk13 with SMTP id jk13so1175652bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 13:41:15 -0700 (PDT)
In-Reply-To: <20120924132637.17d89210@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 13:26 -0700, Stephen Hemminger wrote:
> On Mon, 24 Sep 2012 22:09:50 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 

> > 
> > I am not sure why you remove IFF_XMIT_DST_RELEASE here
> 
> Copied from GRE. What is impact either way? 

GRE needs skb_dst(skb) to be non NULL if tiph->daddr == NULL

but I am not sure your code needs this.

This is a performance issue, for packets waiting in a Qdisc : we'll need
to force a reference (and a cache line false sharing)
