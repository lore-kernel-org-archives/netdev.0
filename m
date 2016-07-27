From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V2 5/5] net/mlx4: Add VST QinQ support
Date: Wed, 27 Jul 2016 11:05:25 -0700
Message-ID: <5798F7E5.1020309@gmail.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
 <1469445336-21952-6-git-send-email-tariqt@mellanox.com>
 <5796488E.7080401@gmail.com> <653875ea-f06b-e850-d5d2-1c248b2341a6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36799 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbcG0SFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 14:05:38 -0400
Received: by mail-pf0-f179.google.com with SMTP id h186so13056843pfg.3
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 11:05:38 -0700 (PDT)
In-Reply-To: <653875ea-f06b-e850-d5d2-1c248b2341a6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-26 07:23 AM, Tariq Toukan wrote:
> Hi John,
> 
> Currently we support one tag set to a VF by the administrator, with the
> new interface can be either C-VLAN or S-VLAN.
> Once S-VLAN is set by administrator, the VM can set the C-VLANs it wants
> to use.
> 
> S-VLAN + C-VLAN per vf currently is not supported, but can be a future
> use case.
> Command line in such case should add more tuples of {vlan, qos, proto}
> such as:
> ip link set dev ens2 vf 0 vlan 100  qos 2 proto 802.1ad vlan 50 qos 4
> proto 802.1q
> 

yep looks good to me.

> As we currently don't support it, we will change the new
> IFLA_VF_VLAN_INFO struct to include a list of such tuples and currently
> use only the first one.
> Is that what you meant?
> 

Yep that was exactly my suggestion. Because I know hardware that
supports the double tag mode and as soon as someone sees they can
change the proto they will ask me to support double tags.

There are two approaches to this either make the struct understand
a list of tags or build it into the netlink message using netlink
TLV constructs. I'm OK with either approach take a look at the code
and see how it looks.

Thanks for working on this.

> Regards,
> Tariq and Moshe
> 
