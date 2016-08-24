From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for
 ndo_set_vf_vlan
Date: Wed, 24 Aug 2016 08:31:58 +0000
Message-ID: <CO2PR11MB0088077BE20D123DD6BB119297EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
 <SN2PR11MB009472734B1803F20C4A9B1497EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
 <20160824082249.GB9955@hari-Latitude-E5550>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0126.outbound.protection.outlook.com ([104.47.34.126]:40395
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755378AbcHXIcw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 04:32:52 -0400
In-Reply-To: <20160824082249.GB9955@hari-Latitude-E5550>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > @@ -1202,6 +1202,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct
> > > net_device *dev)
> > >  	BUG_ON(qidx >=3D pi->nqsets);
> > >  	txq =3D &adapter->sge.ethtxq[pi->first_qset + qidx];
> > >
> > > +	if (pi->vlan_id && !skb_vlan_tag_present(skb))
> > > +		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
> > > +				       pi->vlan_id);
> > > +
> >
> > So it's a purely SW implementation of the feature on the VF side?
> > Does the HW enforces the configuration in any way on the VF?
> Basically the PF driver passes the VLAN ID it got through ndo_set_vf_vlan=
 to the
> VF driver. And then the VF driver reads it and requests hardware to tag i=
t.

Problem with SW implementations is mainly that they have no effect over
Malicious VFs
 I.e., if the purpose here is to add the VF to some vlan-tagged subnet
Whereas the user is oblivious to it, a malicious user can easily modify
the driver to ignore this restriction and get access to the entire network.

I think one of the problems with this ndo is that it's poorly documented
and thus open for various interpretations - so it's debatable what's import=
ant
and what's not. [If it is properly documented anywhere, please educate me]

> > Also, looks like an already tagged packet would be processed with the
> > original vlan-id [instead of the one of PF has provided].
> > Is that intentional?
> No, this isn't intentional. I thought VST and VGT cannot co-exist.
> What should be the behavior?

Are you preventing VGT configuration once VST is configured?
If not, what to prevent VM user from configuring vlan interfaces
on top of the VF, even if VST is configured?
