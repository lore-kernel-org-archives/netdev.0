From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2 1/2] be2net: add FW cmds needed for VxLAN
 offloads
Date: Mon, 24 Mar 2014 07:49:59 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C2A41633E@CMEXMB1.ad.emulex.com>
References: <1395640827-23142-1-git-send-email-sathya.perla@emulex.com>
	<1395640827-23142-2-git-send-email-sathya.perla@emulex.com>
 <CAJZOPZJj-aPskQfDAFiUE6Oa5J71EyUX6UabGOCkGhKTyLkyBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:37150 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaCXHuA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 03:50:00 -0400
In-Reply-To: <CAJZOPZJj-aPskQfDAFiUE6Oa5J71EyUX6UabGOCkGhKTyLkyBA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> 
> On Mon, Mar 24, 2014 at 8:00 AM, Sathya Perla <sathya.perla@emulex.com> >
> 
> +void be_reset_nic_desc(struct be_nic_res_desc *nic)
> > +{
> > +       memset(nic, 0, sizeof(*nic));
> > +       nic->unicast_mac_count = 0xFFFF;
> > +       nic->mcc_count = 0xFFFF;
> > +       nic->vlan_count = 0xFFFF;
> > +       nic->mcast_mac_count = 0xFFFF;
> > +       nic->txq_count = 0xFFFF;
> > +       nic->rq_count = 0xFFFF;
> > +       nic->rssq_count = 0xFFFF;
> > +       nic->lro_count = 0xFFFF;
> > +       nic->cq_count = 0xFFFF;
> > +       nic->toe_conn_count = 0xFFFF;
> > +       nic->eq_count = 0xFFFF;
> > +       nic->link_param = 0xFF;
> > +       nic->acpi_params = 0xFF;
> > +       nic->wol_param = 0x0F;
> > +       nic->bw_min = 0xFFFFFFFF;
> > +       nic->bw_max = 0xFFFFFFFF;
> 
> maybe some sort of memset can do as well?

This is old code that I just wrapped-up in a routine as a part of this patch, to help
with re-factoring of be_cmd_set_profile_config() needed for vxlan setting.
I'd like to take up any cleanup of this code as a part of a separate patch and not this patch-set.

Also, if you observe the be_nic_res_desc{} struct, the fields that require
re-setting with 0xFFFF (count fields and params that are to remain unchanged)
are all not contiguous. So, just memset-ing a region of memory doesn't necessarily work here.

thanks,
-Sathya
