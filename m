From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] net: Add SRIOV VGT+ support
Date: Tue, 29 Aug 2017 13:13:09 +0300
Message-ID: <CALzJLG8EqGLw66bzBdor629mvJdcN+YOAesTxW8_QYt_teUMiA@mail.gmail.com>
References: <20170827110618.20599-1-saeedm@mellanox.com> <20170827110618.20599-2-saeedm@mellanox.com>
 <20170828155217.GA8399@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36430 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdH2KNb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 06:13:31 -0400
Received: by mail-lf0-f68.google.com with SMTP id l140so1834491lfg.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 03:13:30 -0700 (PDT)
In-Reply-To: <20170828155217.GA8399@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 6:52 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2017-08-27, 14:06:15 +0300, Saeed Mahameed wrote:
> [...]
>> +#define VF_VLAN_BITMAP       DIV_ROUND_UP(VF_VLAN_N_VID, sizeof(__u64) * BITS_PER_BYTE)
>> +struct ifla_vf_vlan_trunk {
>> +     __u32 vf;
>> +     __u64 allowed_vlans_8021q_bm[VF_VLAN_BITMAP];
>> +     __u64 allowed_vlans_8021ad_bm[VF_VLAN_BITMAP];
>> +};
>
> This is huge (1032B). And you put one of these in the netlink message
> for each VF.  This means that with 51 VF (at least in my environment,
> where each VF takes 1296B), you're going to overflow the u16 size of a
> single attribute (IFLA_VFINFO_LIST), and you cannot dump the device
> anymore. I'm afraid this is going to break existing setups.
>

Yes ! We will fix this,
we are considering to report only a boolean in VFINFO which indecates
if VGT+ is enable or not
and provide a new attribute per VF to report only the vlan list of specific VF.

Thanks for the input,
we will handle this.


> --
> Sabrina
