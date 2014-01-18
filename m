From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: move the netdev_add_tso_features() to
 bonding module
Date: Sat, 18 Jan 2014 09:08:43 -0800
Message-ID: <1390064923.31367.531.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52DA3BE5.5020500@huawei.com>
	 <20140118114801.GA30549@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:48829 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaARRIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 12:08:45 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so5325492pad.41
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 09:08:44 -0800 (PST)
In-Reply-To: <20140118114801.GA30549@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-18 at 12:48 +0100, Veaceslav Falico wrote:
> On Sat, Jan 18, 2014 at 04:31:33PM +0800, Ding Tianhong wrote:
> >The function netdev_add_tso_features() was only be used for bonding,
> >so no need to export it in netdevice.h, move it to bonding module.
> 
> Eric added it for a reason - like, other drivers might use it. Do you know
> if team, bridge, vlan etc. might use it?

A helper can be used once, this is fine. A car can have 4 seats, and can
even be used with no passenger.

I am quite bored by patches that break clean layering for wrong reasons.


static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
                                                      netdev_features_t mask)
{
      return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
}

There is _nothing_ in this helper that implies it should be private to bonding.
