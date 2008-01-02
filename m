From: "Rami Rosen" <ramirose@gmail.com>
Subject: Re: [PATCH net-2.6.25] [BRIDGE] Remove useless code in net/bridge/br_netfilter.c
Date: Wed, 2 Jan 2008 08:16:54 +0200
Message-ID: <eb3ff54b0801012216r486ba195p127d9f9102143c84@mail.gmail.com>
References: <eb3ff54b0801010248t65d296ccm481202d50fad7c4f@mail.gmail.com>
	 <20080101.212026.187527188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:46200 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093AbYABGQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 01:16:56 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3083895fga.17
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 22:16:55 -0800 (PST)
In-Reply-To: <20080101.212026.187527188.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
> It's a pointer dereference assignment,
Sorry, I was wrong here !

> What automated tool showed this as useless to you?
> Please correct it's logic so it doesn't mark real side effects like
> this as superfluous.

I am not using any automated tool, only my eyes. And I
missed the intention here. It could be implemnted differently
but since it not marked as superfluous anywhere I suggest
to leave it as it is.

Sorry,

Regards,
Rami Rosen





On Jan 2, 2008 7:20 AM, David Miller <davem@davemloft.net> wrote:
> From: "Rami Rosen" <ramirose@gmail.com>
> Date: Tue, 1 Jan 2008 12:48:14 +0200
>
> > These following two commands in br_nf_forward_arp() achieve nothing and
> > should be removed; the d variable is not used later in this method:
> >
> >       ...
> >       struct net_device **d = (struct net_device **)(skb->cb);
> >       ...
> >       *d = (struct net_device *)in;
> >       ...
> >
> > Signed-off-by: Rami Rosen <ramirose@gmail.com>
>
> It's a pointer dereference assignment, this last line has a
> side effect, therefore you can't remove it.
>
> The code is equivalent to:
>
> struct skb_bridge_info {
>         struct net_device *dev;
> };
>
>         struct skb_bridge_info *d;
>
>         d = (struct skb_bridge_info *) skb->cb;
>
>         d->dev = in;
>
> What automated tool showed this as useless to you?
>
> Please correct it's logic so it doesn't mark real side effects like
> this as superfluous.
>
> Thanks.
>
