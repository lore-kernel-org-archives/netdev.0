From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 01 Mar 2012 08:24:22 -0500
Message-ID: <1330608262.6944.10.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu>  <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu>  <4F4DAC26.4050108@intel.com>
	 <1330523779.18226.17.camel@mojatatu>  <4F4E5FA4.4040506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Lennert Buytenhek <buytenh@wantstofly.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F4E5FA4.4040506@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-29 at 09:25 -0800, John Fastabend wrote:

> Well I think NETLINK_ROUTE is the most correct type to use in this
> case. Per netlink.h its for routing and device hooks.
> 
> #define NETLINK_ROUTE           0       /* Routing/device hook                          */
> 
> And NETLINK_ROUTE msg_types use the RTM_* prefix. The _*NEIGH postfix
> were merely a copy from the SW BRIDGE code paths. How about,
> 
> PF_BRIDGE:RTM_FDB_NEWENTRY
> PF_BRIDGE:RTM_FDB_DELENTRY
> PF_BRIDGE:RTM_FDB_GETENTRY

OK, I guess ;->

> And a new group RTNLGRP_FDB. 

Nod.

> Also using NETLINK_ROUTE gives the correct
> rtnl locking semantics for free.

makes sense.


> Agreed. I think adding some ndo_ops for bridging offloads here would
> work. For example the DSA infrastructure and/or macvlan devices might
> need this. Along the lines of extending this RFC,
> 
> [RFC] hardware bridging support for DSA switches
> http://patchwork.ozlabs.org/patch/16578/

Certainly - thats one approach that is reasonable.
Where is Lennert? ;-> I changed his email address to one that i am 
familiar with.

cheers,
jamal


