From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Tue, 02 Oct 2007 08:37:07 -0400
Message-ID: <1191328627.4353.15.camel@localhost>
References: <1191175890.6165.17.camel@localhost>
	 <1191284504.25892.129.camel@dell>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:27367 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbXJBMhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 08:37:33 -0400
Received: by wr-out-0506.google.com with SMTP id 36so2128424wra
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 05:37:33 -0700 (PDT)
In-Reply-To: <1191284504.25892.129.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-10 at 17:21 -0700, Michael Chan wrote:

> Jamal, in tg3_enqueue_buggy(), we may have to call tg3_tso_bug() which
> will recursively call tg3_start_xmit_dma_bug() after segmenting the TSO
> packet into normal packets.  We need to restore the VLAN tag so that the
> GSO code will create the chain of segmented SKBs with the proper VLAN
> tag.

Excellent eye Michael.
The simplest solution seems to me to modify the definition of TG3_SKB_CB
as i did for e1000 from:
(struct tg3_tx_cbdata *)&((__skb)->cb[0])
to:
(struct tg3_tx_cbdata *)&((__skb)->cb[8])

that way the vlan tags are always present and no need to recreate them.
What do you think?

cheers,
jamal

