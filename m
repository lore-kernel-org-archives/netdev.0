From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Mon, 14 Oct 2013 14:41:56 -0700
Message-ID: <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>
References: <525C62D5.3090004@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:42980 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3JNVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 17:42:00 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so7916251pbb.10
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 14:41:59 -0700 (PDT)
In-Reply-To: <525C62D5.3090004@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Oct 2013 17:32:05 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> IOW, TheCutNpasteTrain.
> 
> There's a lot of clutter on the netlink interface used
> by bridge and vxlan.
> 1) A lot of things which are boolean on/off end up using a uchar.
> Example:
> IFLA_BRPORT_MODE, IFLA_BRPORT_GUARD, IFLA_BRPORT_PROTECT,
> IFLA_BRPORT_LEARNING, IFLA_BRPORT_UNICAST_FLOOD, BRIDGE_VLAN_INFO_PVID,
> BRIDGE_VLAN_INFO_UNTAGGED, BRIDGE_MODE_VEPA,
> IFLA_VXLAN_PROXY,IFLA_VXLAN_RSC, etc
> 
> 2) There's a few fields which are basically intended to project the
> same message to the kernel but are redefined a few times:
> Example:
> BRIDGE_VLAN_INFO_MASTER vs NTF_MASTER vs BRIDGE_FLAGS_MASTER
> 
> Also i am not sure why multicast snooping needs its own subheader.
> 
> Is it too late to make changes? git logs shows some of these feature
> have only been on the last 2-3 months.
> One approach to resolve this is introduce a new BRIDGE_FLAGS TLV
> which will work like the ifi_flags/change and put all these flags in
> one spot. New iproute will use these and the old one will continue using
> the old approach. It would require to EOL the old interface at some
> point.

Unfortunately, by now this is all set in ABI.
It was a side effect of the per-feature evolutionary style of development.
