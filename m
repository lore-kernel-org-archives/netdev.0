From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Thu, 21 Sep 2017 14:34:02 -0700
Message-ID: <1506029642.29839.151.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
         <20170812142358.08291888@redhat.com>
         <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
         <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
         <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
         <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
         <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
         <5d32f5cf-ca69-1f6b-5bca-cdcd4dc414e2@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:51200 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUVeD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:34:03 -0400
Received: by mail-pf0-f170.google.com with SMTP id b70so3830098pfl.8
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 14:34:03 -0700 (PDT)
In-Reply-To: <5d32f5cf-ca69-1f6b-5bca-cdcd4dc414e2@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-21 at 23:26 +0200, Paweł Staszewski wrote:
> 
> W dniu 2017-08-15 o 11:11, Paweł Staszewski pisze:
> > diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
> > index 
> > 5e831de3103e2f7092c7fa15534def403bc62fb4..9472de846d5c0960996261cb2843032847fa4bf7 
> > 100644
> > --- a/net/8021q/vlan_netlink.c
> > +++ b/net/8021q/vlan_netlink.c
> > @@ -143,6 +143,7 @@ static int vlan_newlink(struct net *src_net, 
> > struct net_device *dev,
> >       vlan->vlan_proto = proto;
> >       vlan->vlan_id     = nla_get_u16(data[IFLA_VLAN_ID]);
> >       vlan->real_dev     = real_dev;
> > +    dev->priv_flags |= (real_dev->priv_flags & IFF_XMIT_DST_RELEASE);
> >       vlan->flags     = VLAN_FLAG_REORDER_HDR;
> >         err = vlan_check_real_dev(real_dev, vlan->vlan_proto, 
> > vlan->vlan_id); 
> 
> Any plans for this patch to go normal into the kernel ?
> 
> So far im using it for about 3 weeks on all my linux based routers - and 
> no problems.

Yes, I was about to submit it, as I mentioned it few hours ago to you ;)
