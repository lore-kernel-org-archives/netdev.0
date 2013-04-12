From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 02/11] ixgbe: Mask off check of frag_off as we only
 want fragment offset
Date: Fri, 12 Apr 2013 06:45:32 -0700
Message-ID: <1365774332.4459.24.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365765866-15741-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365773328.4459.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:46930 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab3DLNpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:45:35 -0400
Received: by mail-pb0-f53.google.com with SMTP id un15so1426705pbc.12
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:45:34 -0700 (PDT)
In-Reply-To: <1365773328.4459.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 06:28 -0700, Eric Dumazet wrote:

> I wonder if you could use core functions instead of all this...
> 
> A simple wrapper would be :

Or more something like :

static noinline unsigned int ixgbe_get_headlen(unsigned char *data,
                                                u32 maxlen)
{
    struct skb fake;
    unsigned int res;

    if (maxlen < ETH_HLEN)
	return maxlen;

    fake->data = data + ETH_HLEN;
    fake->head = data;
    fake->data_len = 0;
    fake->len = maxlen - ETH_HLEN;
    skb_reset_network_header(&fake);
    res = __skb_get_poff(&fake);
    return res ? res + ETH_HLEN : maxlen;
}
