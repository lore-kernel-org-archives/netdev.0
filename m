From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for
 ndo_set_vf_vlan
Date: Wed, 24 Aug 2016 13:52:50 +0530
Message-ID: <20160824082249.GB9955@hari-Latitude-E5550>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
 <SN2PR11MB009472734B1803F20C4A9B1497EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16274 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754658AbcHXIY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 04:24:58 -0400
Content-Disposition: inline
In-Reply-To: <SN2PR11MB009472734B1803F20C4A9B1497EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 08/24/16, 2016 at 07:08:14 +0000, Yuval Mintz wrote:
> > @@ -1202,6 +1202,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct
> > net_device *dev)
> >  	BUG_ON(qidx >= pi->nqsets);
> >  	txq = &adapter->sge.ethtxq[pi->first_qset + qidx];
> > 
> > +	if (pi->vlan_id && !skb_vlan_tag_present(skb))
> > +		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
> > +				       pi->vlan_id);
> > +
> 
> So it's a purely SW implementation of the feature on the VF side?
> Does the HW enforces the configuration in any way on the VF?
Basically the PF driver passes the VLAN ID it got through ndo_set_vf_vlan
to the VF driver. And then the VF driver reads it and requests hardware to
tag it.

> 
> Also, looks like an already tagged packet would be processed with
> the original vlan-id [instead of the one of PF has provided].
> Is that intentional?
No, this isn't intentional. I thought VST and VGT cannot co-exist.
What should be the behavior? 

Thanks,
Hariprasad Shenai
 
