From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Tue, 22 Nov 2016 13:49:36 +0100
Message-ID: <20161122124936.GA1819@nanopsycho>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@mellanox.com, idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35236 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932329AbcKVMtj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 07:49:39 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so3586428wme.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 04:49:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161121190925.14530-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 21, 2016 at 08:09:22PM CET, f.fainelli@gmail.com wrote:
>Hi all,
>
>This patch series allows using the bridge master interface to configure
>an Ethernet switch port's CPU/management port with different VLAN attributes than
>those of the bridge downstream ports/members.
>
>Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
>tested this with b53 and a mockup DSA driver.

Patchset looks fine to me.

>
>Open questions:
>
>- if we have more than one bridge on top of a physical switch, the driver
>  should keep track of that and verify that we are not going to change
>  the CPU port VLAN attributes in a way that results in incompatible settings
>  to be applied

Ack. In mlxsw this is tracked


>
>- if the default behavior is to have all VLANs associated with the CPU port
>  be ingressing/egressing tagged to the CPU, is this really useful?
>
>Florian Fainelli (3):
>  net: bridge: Allow bridge master device to configure switch CPU port
>  net: dsa: Propagate VLAN add/del to CPU port(s)
>  net: dsa: b53: Remove CPU port specific VLAN programming
>
> drivers/net/dsa/b53/b53_common.c | 22 ++++++--------------
> net/bridge/br_vlan.c             | 28 ++++++++++++++++++++++---
> net/dsa/slave.c                  | 45 +++++++++++++++++++++++++++++-----------
> 3 files changed, 64 insertions(+), 31 deletions(-)
>
>-- 
>2.9.3
>
