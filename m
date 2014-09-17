From: Florian Westphal <fw@strlen.de>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 23:28:49 +0200
Message-ID: <20140917212849.GA8484@breakpoint.cc>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
 <CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
 <20140917190626.GA11354@breakpoint.cc>
 <5419F17D.2090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Cong Wang <cwang@twopensource.com>,
	Francesco Ruggeri <fruggeri@arista.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33245 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755552AbaIQV2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 17:28:55 -0400
Content-Disposition: inline
In-Reply-To: <5419F17D.2090409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 09/17/2014 03:06 PM, Florian Westphal wrote:
> > Cong Wang <cwang@twopensource.com> wrote:
> >> On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
> >>> This used to work in older releases.
> >>> The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
> >>> on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
> >>> to inherit its features from the lower device.
> >>>
> >>> Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
> >>> lower device
> >>> by macvlan interfaces?
> >>
> >> commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
> >> so just clear this flag. Please submit a patch.
> > 
> > Under which conditions would NETIF_F_NETNS_LOCAL have to be inherited?
> > (i.e., why is it inheritable in the first place?)

To answer my own question:  Its inherited since lowerdev->features is
passed as 'all' flag, so we would 'decrement' feature set if we'd remove
it in _increment_features().

> macvlan code calls
>         features = netdev_increment_features(vlan->lowerdev->features,
>                                              features,
>                                              mask);
> 
> where lowerdev->features contains the NETIF_F_NETNS_LOCAL bit.  That

[..]

> May be a better solution is:
> 
>         features = netdev_increment_features(vlan->lowerdev->features & MACVLAN_FEATURS,
>                                              features,
>                                              mask);
> 
> This way we start with only the feature MACVLAN is interested in.

Seems correct, since it will also prevent other non-macvlan features from
appearing.

Thanks Vlad.
