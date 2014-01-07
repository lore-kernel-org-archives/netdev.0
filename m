From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 07 Jan 2014 13:38:13 -0800
Message-ID: <1389130693.26646.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	 <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
	 <1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>
	 <1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:59108 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbaAGViT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:38:19 -0500
Received: by mail-qa0-f42.google.com with SMTP id ii20so1112886qab.29
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 13:38:17 -0800 (PST)
In-Reply-To: <CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 22:37 +0200, Or Gerlitz wrote:

> So here's the thing, per my understanding we want to GRO only received
> **encapsulated** packets whose checksum status is != CHECKSUM_NONE
> which means the NIC has some support for doing RX checksum of
> encapsulated packets. Per the current convension, in that case the NIC
> RX code has to set skb->encapsulation see 6a674e9c75b17 "net: Add
> support for hardware-offloaded encapsulation" this convension is
> implemented in the current drivers that have HW offloads for
> encapsulated packets (bnx2x, i40e and mlx4)

I do not think its true.

Some drivers set CHECKSUM_COMPLETE even for regular UDP frames...

git grep -n CHECKSUM_COMPLETE -- drivers/net
