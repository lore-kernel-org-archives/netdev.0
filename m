From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Tue, 18 Apr 2017 15:05:35 -0400
Message-ID: <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
 <CACKFLikm1vDzz8eQJMJOEsbv-NNV41ki2TEPVPCSpP6VjaowBA@mail.gmail.com>
 <20170413.162315.1889531431093534154.davem@davemloft.net>
 <20170415005949.GB73685@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33856 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754811AbdDRTFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:05:45 -0400
Received: by mail-oi0-f65.google.com with SMTP id t14so444553oif.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 12:05:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170415005949.GB73685@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 05:59:51PM -0700, Alexei Starovoitov wrote:
> On Thu, Apr 13, 2017 at 04:23:15PM -0400, David Miller wrote:
> > +
> > +	switch (act) {
> > +	case XDP_TX:
> > +		__skb_push(skb, skb->mac_len);
> 
> s/skb->mac_len/mac_len/
> 

I was away from my keyboard for a few days, but was able to get some
time to test this today.

When using this change above suggested by Alexei, XDP_DROP and XDP_TX
actions appear to work well with xdp1 and xdp2.

I'm seeing some rather odd behavior with xdp_tx_tunnel so it might be
good to hold off on committing this just yet.

At first glance, it looks like there is enough headroom for the new
frame, but the resulting packet data do not look right and I'm actually
seeing some data that may be left on the stack from a previous caller.

> > +	HARD_TX_UNLOCK(dev, txq);
> > +	if (free_skb) {
> > +		trace_xdp_exception(dev, xdp_prog, XDP_TX);
> > +		kfree_skb(skb);
> 
> nice that you didn't forget to add trace_xdp_exception in this path :)
> 
> Overall looks good to me and other than the minor nit in tx, i think it
> should work for programs already used with in-driver xdp.
> I'll test it next week unless people beat me to it.
> 
