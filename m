From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 24/27] netfilter: guarantee 8 byte minalign for template
 addresses
Date: Mon, 6 Feb 2017 10:08:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027C5AF@AcuExch.aculab.com>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
 <1486124738-3013-25-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:54248 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751456AbdBFKI2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 05:08:28 -0500
In-Reply-To: <1486124738-3013-25-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso
> Sent: 03 February 2017 12:26
> The next change will merge skb->nfct pointer and skb->nfctinfo
> status bits into single skb->_nfct (unsigned long) area.
> 
> For this to work nf_conn addresses must always be aligned at least on
> an 8 byte boundary since we will need the lower 3bits to store nfctinfo.

Don't do it then.
You are using a bit somewhere else to allow you to use a 'hack'
that stores 3 status bits into the bottom of an address where there
are only 2 'available' bits.
That sounds like it just adds code everywhere.
I suspect you'll regret doing it later on as well.

	David
