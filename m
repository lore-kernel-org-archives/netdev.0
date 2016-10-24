From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] macsec: Fix header length if SCI is added if
 explicitily disabled
Date: Mon, 24 Oct 2016 13:28:22 +0200
Message-ID: <20161024112822.GA28497@bistromath.localdomain>
References: <bfb9f7ef-39b1-269f-48de-d7caf5c54c2f@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44072 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756858AbcJXL20 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 07:28:26 -0400
Content-Disposition: inline
In-Reply-To: <bfb9f7ef-39b1-269f-48de-d7caf5c54c2f@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-10-21, 13:11:37 +0200, Tobias Brunner wrote:
> Even if sending SCIs is explicitly disabled, the code that creates the
> Security Tag might still decide to add it (e.g. if multiple RX SCs are
> defined on the MACsec interface).
> But because the header length so far only depended on the configuration
> option the SCI might not actually have ended up in the packet, while the
> SC flag in the TCI field of the Security Tag was still set, resulting
> in invalid MACsec frames.

Or overwriting the original frame's contents (ethertype and eg
beginning of the IP header) if !encrypt.


Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")


[snip]
> @@ -440,12 +448,12 @@ static void macsec_fill_sectag(struct macsec_eth_header *h,
>  			       const struct macsec_secy *secy, u32 pn)
>  {
>  	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
> +	bool sci_present = send_sci(secy);

You're already computing this in macsec_encrypt() just before calling
macsec_fill_sectag(), so you could pass it as argument instead of
recomputing it.

Other than that, LGTM, thanks!


-- 
Sabrina
