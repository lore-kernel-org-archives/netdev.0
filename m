From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 1/4] net: Add SRIOV VGT+ support
Date: Tue, 29 Aug 2017 18:43:30 +0200
Message-ID: <20170829164330.GA22607@bistromath.localdomain>
References: <20170827110618.20599-1-saeedm@mellanox.com>
 <20170827110618.20599-2-saeedm@mellanox.com>
 <20170828155217.GA8399@bistromath.localdomain>
 <CALzJLG8EqGLw66bzBdor629mvJdcN+YOAesTxW8_QYt_teUMiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751358AbdH2Qne (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 12:43:34 -0400
Content-Disposition: inline
In-Reply-To: <CALzJLG8EqGLw66bzBdor629mvJdcN+YOAesTxW8_QYt_teUMiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-29, 13:13:09 +0300, Saeed Mahameed wrote:
> On Mon, Aug 28, 2017 at 6:52 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> > 2017-08-27, 14:06:15 +0300, Saeed Mahameed wrote:
> > [...]
> >> +#define VF_VLAN_BITMAP       DIV_ROUND_UP(VF_VLAN_N_VID, sizeof(__u64) * BITS_PER_BYTE)
> >> +struct ifla_vf_vlan_trunk {
> >> +     __u32 vf;
> >> +     __u64 allowed_vlans_8021q_bm[VF_VLAN_BITMAP];
> >> +     __u64 allowed_vlans_8021ad_bm[VF_VLAN_BITMAP];
> >> +};
> >
> > This is huge (1032B). And you put one of these in the netlink message
> > for each VF.  This means that with 51 VF (at least in my environment,
> > where each VF takes 1296B), you're going to overflow the u16 size of a
> > single attribute (IFLA_VFINFO_LIST), and you cannot dump the device
> > anymore. I'm afraid this is going to break existing setups.
> >
> 
> Yes ! We will fix this,
> we are considering to report only a boolean in VFINFO which indecates
> if VGT+ is enable or not
> and provide a new attribute per VF to report only the vlan list of specific VF.

I don't see what this is going to look like. Maybe you can describe
more precisely what you want to add to the netlink message? (otherwise
I'll wait for the patches)

If you add large attributes for each VF, this is still going to break.


Thanks.

-- 
Sabrina
