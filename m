From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix race condition in mvneta_tx()
Date: Tue, 02 Dec 2014 04:37:15 -0800
Message-ID: <1417523835.5303.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
	 <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417523459.5303.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:54673 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbaLBMhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 07:37:17 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so11369820ier.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 04:37:17 -0800 (PST)
In-Reply-To: <1417523459.5303.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 04:30 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> mvneta_tx() dereferences skb to get skb->len too late,
> as hardware might have completed the transmit and TX completion
> could have freed the skb from another cpu.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>



For completeness, this bug was added in linux-3.14 and seems a stable
candidate.

Fixes: 71f6d1b31fb1 ("net: mvneta: replace Tx timer with a real interrupt")
