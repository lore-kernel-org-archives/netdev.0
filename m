From: "Yang, Yi Y" <yi.y.yang@intel.com>
Subject: RE: [PATCH net-next v2] openvswitch: enable NSH support
Date: Fri, 11 Aug 2017 09:24:25 +0000
Message-ID: <79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
        <20170811102418.6b1be4f7@griffin>
        <20170811084722.GA19968@cran64.bj.intel.com>
 <20170811111055.482bd42b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        Jan Scheurich <jan.scheurich@ericsson.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35630 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751818AbdHKJY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 05:24:28 -0400
In-Reply-To: <20170811111055.482bd42b@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, we're not clear how we can support MD type 2 better, as I explained before, we need to reuse tun_metadata in struct flow_tnl which is the thing Geneve is using. Geneve predefined 64 keys for this from tun_metadata0 to tun_metadata63, we will reuse it for MD type 2. But you know NSH is not tunnel, so it has to be changed to support both Geneve and NSH. Anyway, they won't be part of ovs_key_nsh.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jiri Benc
Sent: Friday, August 11, 2017 5:11 PM
To: Yang, Yi Y <yi.y.yang@intel.com>
Cc: netdev@vger.kernel.org; dev@openvswitch.org
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support

On Fri, 11 Aug 2017 16:47:23 +0800, Yang, Yi wrote:
> is "__be32 context[4]" ok?

Yes, that looks better.

> So define three new netlink attributes
> 
> OVS_ACTION_ATTR_NSH_BASE_HEADER
> OVS_ACTION_ATTR_NSH_MD1_DATA
> OVS_ACTION_ATTR_NSH_MD2_DATA
> 
> OVS_ACTION_ATTR_PUSH_NSH is nested netlink attribute, it will nest 
> OVS_ACTION_ATTR_NSH_BASE_HEADER and OVS_ACTION_ATTR_NSH_MD1_DATA for 
> MD type 1, it will nest OVS_ACTION_ATTR_NSH_BASE_HEADER and 
> OVS_ACTION_ATTR_NSH_MD2_DATA for MD type 2. I'll compeletely remove 
> struct ovs_action_push_nsh, is it ok?

Yes, that's the way to do it.

What should be done with struct ovs_key_nsh? Even with "c" renamed to "context", it's still MD type 1 only structure. What is the plan for MD type 2 support wrt. this structure?

Thanks,

 Jiri
