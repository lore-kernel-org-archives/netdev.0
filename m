From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 06 Feb 2013 08:15:32 -0800
Message-ID: <1360167332.28557.36.camel@edumazet-glaptop>
References: <20130206114321.GA13497@redhat.com>
	 <1360156059.28557.28.camel@edumazet-glaptop>
	 <20130206155049.GB14735@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:33154 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab3BFQPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:15:37 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so724649dam.4
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 08:15:35 -0800 (PST)
In-Reply-To: <20130206155049.GB14735@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:

> Also, I'm not sure I understand when should drivers set gso size
> for incoming messages and what is a reasonable value.
> Commit log talks about improved performance for lossy connections,
> in this case, isn't this something net core should set?
> 
> I see 3 in-tree drivers that do this:
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:                skb_shinfo(skb)->gso_size = bnx2x

bnx2x is fine, take a look at lines 464

> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:  skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->le
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:         skb_shinfo(skb)->gso_size = qlcnic_get_lr
> 
> It seems likely the same issue applies there?

Yes
