From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: make skb_set_owner_w() more robust
Date: Mon, 02 Nov 2015 12:09:25 -0800
Message-ID: <1446494965.23275.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151101.155859.1206189858863918018.davem@davemloft.net>
	 <1446417380.6254.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446418728.6254.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446421015.6254.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB0770C038C9E0F34EBCCB605FCA2C0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34059 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbbKBUJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:09:27 -0500
Received: by padec8 with SMTP id ec8so48769559pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 12:09:26 -0800 (PST)
In-Reply-To: <BN1PR0301MB0770C038C9E0F34EBCCB605FCA2C0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 20:05 +0000, Haiyang Zhang wrote:

> Thanks for the fix!
> For some driver, like ours, this condition may not be "unlikely".
> So could you remove the "unlikely"?

No, I wont remove the unlikely.

Look, your main issue is about reallocating skbs, because of excessive
dev->needed_headroom.

An unlikely() mismatch is 1000 times less expensive, why would you
care ?

If you really care, fix your driver to not abuse skb->head to store 220
bytes of private data.
