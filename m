From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for
 ndo_set_vf_vlan
Date: Wed, 24 Aug 2016 10:02:57 +0000
Message-ID: <CO2PR11MB00884270FCB88896B9B1754B97EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
 <SN2PR11MB009472734B1803F20C4A9B1497EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
 <20160824082249.GB9955@hari-Latitude-E5550>
 <CO2PR11MB0088077BE20D123DD6BB119297EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <20160824094003.GA21672@hari-Latitude-E5550>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0116.outbound.protection.outlook.com ([104.47.33.116]:48973
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754046AbcHXKjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 06:39:25 -0400
In-Reply-To: <20160824094003.GA21672@hari-Latitude-E5550>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Are you preventing VGT configuration once VST is configured?
> > If not, what to prevent VM user from configuring vlan interfaces on
> > top of the VF, even if VST is configured?
> Again this misses documentation, what if VLAN interface is already config=
ured in
> VM before VST is configured.
> Before there were callbacks to add/remove vlan interface, now that is rem=
oved
> how to achieve it?
>     OR
> am I missing something?

I can only offer what our drivers [bnx2x, qed*] are doing -=20
  -  VST is achieved by FW adding the vlan tag [unknowingly to VF] on egres=
s traffic,
and silently stripping the vlan tag from the incoming traffic [so VF driver=
 never
sees the tag].
  - Once VST is enabled, device [well, actually PF driver] would reject any=
 further
requests for configuring VGT.
  - Once VST is configured, device would silently drop any vlan-tagged egre=
ss
Traffic sent  by VF, and would classify incoming traffic for that VF only i=
f it's
tagged with the VGT vlan-id.
This has the effect of making existing vlan-interface over the VF completel=
y
dysfunctional [as all transmissions from them would be dropped and they'll
never see any additional incoming traffic].
