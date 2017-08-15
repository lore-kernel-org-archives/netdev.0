From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 12:05:39 +0200
Message-ID: <20170815120539.792f357d@redhat.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
        <20170812142358.08291888@redhat.com>
        <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
        <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
        <20170814181957.5be27906@redhat.com>
        <1502729870.8411.63.camel@redhat.com>
        <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
        <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
        <1502759849.4936.46.camel@edumazet-glaptop3.roam.corp.google.com>
        <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com
To: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40522 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753276AbdHOKFp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 06:05:45 -0400
In-Reply-To: <4b1efff7-4f91-fd78-beb8-2c7ebcf18895@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 15 Aug 2017 11:11:57 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:

> Yes it helped - now there is almost no difference when using vlans or not:
> 
> 10.5Mpps - with vlan
> 
> 11Mpps - without vlan

Great! - it seems like we have pinpointed the root-cause.  It also
demonstrate how big the benefit is of Eric commit (thanks!):
 https://git.kernel.org/torvalds/c/93f154b594fe


> W dniu 2017-08-15 o 03:17, Eric Dumazet pisze:
> > On Mon, 2017-08-14 at 18:07 -0700, Eric Dumazet wrote:
> >  
> >> Or try to hack the IFF_XMIT_DST_RELEASE flag on the vlan netdev.  
> > Something like :
> >
> > diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
> > index 5e831de3103e2f7092c7fa15534def403bc62fb4..9472de846d5c0960996261cb2843032847fa4bf7 100644
> > --- a/net/8021q/vlan_netlink.c
> > +++ b/net/8021q/vlan_netlink.c
> > @@ -143,6 +143,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
> >   	vlan->vlan_proto = proto;
> >   	vlan->vlan_id	 = nla_get_u16(data[IFLA_VLAN_ID]);
> >   	vlan->real_dev	 = real_dev;
> > +	dev->priv_flags |= (real_dev->priv_flags & IFF_XMIT_DST_RELEASE);
> >   	vlan->flags	 = VLAN_FLAG_REORDER_HDR;
> >   
> >   	err = vlan_check_real_dev(real_dev, vlan->vlan_proto, vlan->vlan_id);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
