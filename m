From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3 1/4] ieee802154: add
 generic header handling routines
Date: Tue, 4 Mar 2014 15:14:08 +0100
Message-ID: <20140304141406.GA4762@omega>
References: <1393884475-20927-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
 <1393884475-20927-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:36335 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329AbaCDOOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 09:14:16 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so2363130eei.28
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 06:14:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393884475-20927-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phoebe,

On Mon, Mar 03, 2014 at 11:07:52PM +0100, Phoebe Buckheister wrote:
> Add a generic set of 802.15.4 header operations on sk_buffs: push header
> onto skb, pull header from skb, and peek address fields from the mac_hdr
> part of an skb.
> 
> These routines support the full 802.15.4 header as described in the
> standard, including the security header. They are useful for everything
> that must create, modify or read 802.15.4 headers, which of course
> includes the wpan rx/tx path, but also 6lowpan. In the future,
> link-layer security will also require means to modify packet headers.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> Tested-by: Alexander Aring <alex.aring@gmail.com>
> ---
> +static int
> +ieee802154_hdr_get_addrs(const u8 *buf, struct ieee802154_hdr *hdr)
> +{
> +	int pos = 0;
> +
> +	pos += ieee802154_hdr_get_addr(buf + pos,
> +				       IEEE802154_FC_DAMODE(hdr->fc),
> +				       false, &hdr->dest);
> +	pos += ieee802154_hdr_get_addr(buf + pos,
> +				       IEEE802154_FC_SAMODE(hdr->fc),
> +				       hdr->fc & IEEE802154_FC_INTRA_PAN,
> +				       &hdr->source);
> +
> +	if (hdr->fc && IEEE802154_FC_INTRA_PAN)
I think this should be:

if (hdr->fc & IEEE802154_FC_INTRA_PAN)

- Alex
