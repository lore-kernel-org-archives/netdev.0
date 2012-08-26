From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues (VMDQ)
Date: Sun, 26 Aug 2012 16:11:28 +0300
Message-ID: <CAJZOPZJBhDdQp2-8WG-UsToPHwyawYYVctqjZMT8JN85DK3XYQ@mail.gmail.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com, shlomop@mellanox.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63181 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab2HZNL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 09:11:29 -0400
Received: by ialo24 with SMTP id o24so6383759ial.19
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 06:11:29 -0700 (PDT)
In-Reply-To: <20120718220544.22619.97136.stgit@i40e.jf1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 1:05 AM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> This adds support to allow virtual net devices to be created. These
> devices can be managed independently of the physical function but
> use the same physical link.
>
> This is analogous to an offloaded macvlan device. The primary
> advantage to VMDQ net devices over virtual functions is they can
> be added and removed dynamically as needed.

Hi John,

When VMDQ devices are opened over a virtual function which is
assigned to guest, the design should include a way to apply the
following ndo_set_vf_yyy  calls to them

int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);


Someone here suggested using a sub-index notation, that is m.n
represents vmdq device index = n on VF index = m where vf.0 is
the non vmdq VF device, makes sense? other thoughts?

Or.
