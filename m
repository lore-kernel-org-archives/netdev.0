From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 1/3] net/core: Add VF link state control
Date: Mon, 10 Jun 2013 18:02:33 +0300
Message-ID: <CAJZOPZ+4_SU3cTYOkukgX4BRZcXOjv-orjoqx_6kVck-607sbA@mail.gmail.com>
References: <1370784435-26055-1-git-send-email-ogerlitz@mellanox.com>
	<1370784435-26055-2-git-send-email-ogerlitz@mellanox.com>
	<1370875176.1933.2.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:38751 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab3FJPCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:02:34 -0400
Received: by mail-qe0-f44.google.com with SMTP id 5so1686216qeb.17
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:02:33 -0700 (PDT)
In-Reply-To: <1370875176.1933.2.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 5:39 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Sun, 2013-06-09 at 16:27 +0300, Or Gerlitz wrote:
> > From: Rony Efraim <ronye@mellanox.com>
> >
> > Add netlink directives and ndo entry to allow for controling
> > VF link, which can be in one of three states:
> >
> > Auto - VF link state reflects the PF link state (default)
> >
> > Up - VF link state is up, traffic from VF to VF works even if
> > the actual PF link is down
> >
> > Down - VF link state is down, no traffic from/to this VF, can be of
> > use while configuring the VF
> >
> > Signed-off-by: Rony Efraim <ronye@mellanox.com>
> > Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> [...]
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -947,6 +947,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,
> > struct net_device *dev,
> >                       struct ifla_vf_vlan vf_vlan;
> >                       struct ifla_vf_tx_rate vf_tx_rate;
> >                       struct ifla_vf_spoofchk vf_spoofchk;
> > +                     struct ifla_vf_link_state vf_linkstate;
> >
> >                       /*
> >                        * Not all SR-IOV capable drivers support the
>
> There's a bit missing here: you need to initialise ivi.linkstate to a
> default value.  I'm not sure whether that should be
> FLA_VF_LINK_STATE_AUTO (i.e. assume that's the default for all drivers/
> hardware) or whether there should be an explicit 'unknown' value.

good catch Ben. Per the discussion held over the RFC thread, the
default is auto and so will be the value I will set here prior to the
call into the drivers.
