From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] openvswitch: introduce rtnl ops stub
Date: Thu, 12 Jun 2014 17:03:26 +0200
Message-ID: <20140612150326.GD2974@minipsycho.orion>
References: <1402582808-10443-1-git-send-email-jiri@resnulli.us>
 <5399BD2D.6050609@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60504 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbaFLPDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 11:03:33 -0400
Received: by mail-wg0-f44.google.com with SMTP id x13so1389074wgg.15
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 08:03:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5399BD2D.6050609@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 12, 2014 at 04:46:05PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 12/06/2014 16:20, Jiri Pirko a =E9crit :
>>This stub now allows userspace to see IFLA_INFO_KIND for ovs master a=
nd
>>IFLA_INFO_SLAVE_KIND for slave.
>>
>>Note that I added ops->setup check into newlink and dellink in order =
to
>>prevent creating and deleting openvswitch instances using rtnl for no=
w.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>net-next is closed ;-)
>
>>---
>>  net/core/rtnetlink.c                 |  5 ++++-
>>  net/openvswitch/datapath.c           |  9 ++++++++-
>>  net/openvswitch/vport-internal_dev.c | 16 ++++++++++++++++
>>  net/openvswitch/vport-internal_dev.h |  2 ++
>>  4 files changed, 30 insertions(+), 2 deletions(-)
>>
>>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>index 233b5ae..b874139 100644
>>--- a/net/core/rtnetlink.c
>>+++ b/net/core/rtnetlink.c
>>@@ -1767,7 +1767,7 @@ static int rtnl_dellink(struct sk_buff *skb, st=
ruct nlmsghdr *nlh)
>>  		return -ENODEV;
>>
>>  	ops =3D dev->rtnl_link_ops;
>>-	if (!ops)
>>+	if (!ops || !ops->setup)
>>  		return -EOPNOTSUPP;
>>
>>  	ops->dellink(dev, &list_kill);
>>@@ -2028,6 +2028,9 @@ replay:
>>  			return -EOPNOTSUPP;
>>  		}
>>
>>+		if (!ops->setup)
>>+			return -EOPNOTSUPP;
>>+
>For this one, you could just add a ops->validate in openvswitch which =
returns
>always -EOPNOTSUPP.

yeah, I wanted the check in newlink and dellink to be the same
