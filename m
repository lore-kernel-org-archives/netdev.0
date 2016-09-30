From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: rtnl: avoid uninitialized data in IFLA_VF_VLAN_LIST handling
Date: Fri, 30 Sep 2016 18:38:05 +0200
Message-ID: <201609301838.05349.arnd@arndb.de>
References: <20160930161416.18660-1-arnd@arndb.de> <CANn89iK2FQufz4NCan1y0dQME2RUOzc3NXXhqYd418ctHNc6fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nogah Frankel <nogahf@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Moshe Shemesh <moshe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:53815 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932988AbcI3Qic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 12:38:32 -0400
In-Reply-To: <CANn89iK2FQufz4NCan1y0dQME2RUOzc3NXXhqYd418ctHNc6fA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 September 2016, Eric Dumazet wrote:
> > @@ -1753,6 +1753,9 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
> >
> >                         len++;
> >                 }
> > +               if (len == 0)
> > +                       return -EINVAL;
> > +
> >                 err = ops->ndo_set_vf_vlan(dev, ivvl[0]->vf, ivvl[0]->vlan,
> >                                            ivvl[0]->qos, ivvl[0]->vlan_proto);
> >                 if (err < 0)
> > --
> > 2.9.0
> >
> 
> So, if I read this code, we build an array, but call ndo_set_vf_vlan()
> only using first element ?
> 
> Looks like the bug should be fixed in a different way.

I was wondering about this too, but didn't understand enough about it to say
if it was intentional or not. I just realized that I forgot to add Moshe and Tariq
on Cc (I relied on scripts/get_maintainer.pl, but didn't double-check).
I've added them to Cc now, hope they can clarify this.

	Arnd
